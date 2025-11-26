# frozen_string_literal: true

require "test_helper"
require "webmock/minitest"

class LeaguepediaServiceTest < ActiveSupport::TestCase
  setup do
    @service = LeaguepediaService.new
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  teardown do
    WebMock.reset!
  end

  # ==========================================
  # fetch_team_by_name tests
  # ==========================================

  test "fetch_team_by_name returns team data when page exists" do
    stub_team_page("T1", team_html_fixture)

    result = @service.fetch_team_by_name("T1")

    assert_not_nil result
    assert_equal "T1", result["Name"]
    assert_equal "T1", result["Short"]
    assert_equal "Korea", result["Region"]
    assert_match(/logo/, result["Image"])
    assert_equal "https://t1.gg", result["Website"]
    assert_equal "0", result["IsDisbanded"]
  end

  test "fetch_team_by_name returns nil when page not found" do
    stub_request(:get, "https://lol.fandom.com/wiki/NonExistentTeam")
      .to_return(status: 404)

    result = @service.fetch_team_by_name("NonExistentTeam")

    assert_nil result
  end

  test "fetch_team_by_name returns nil when infobox not found" do
    html = "<html><body><h1>Team Page</h1><p>No infobox here</p></body></html>"
    stub_team_page("BadTeam", html)

    result = @service.fetch_team_by_name("BadTeam")

    assert_nil result
  end

  test "fetch_team_by_name detects disbanded teams from infobox status" do
    html = <<~HTML
      <html><body>
        <h1 class="mw-page-title-main">DisbandedTeam</h1>
        <table class="infobox">
          <tr><th>Region</th><td>Korea</td></tr>
          <tr><th>Status</th><td>Disbanded</td></tr>
        </table>
      </body></html>
    HTML
    stub_team_page("DisbandedTeam", html)

    result = @service.fetch_team_by_name("DisbandedTeam")

    assert_equal "1", result["IsDisbanded"]
  end

  test "fetch_team_by_name does not detect false positives for inactive mentions" do
    # T1 page mentions "inactive" in context of former players, but team is still active
    html = <<~HTML
      <html><body>
        <h1 class="mw-page-title-main">T1</h1>
        <table class="infobox">
          <tr><th>Region</th><td>Korea</td></tr>
          <tr><th>Short</th><td>T1</td></tr>
        </table>
        <div class="content">
          <h2>Former Roster</h2>
          <p>Zeus and Gumayusi are now inactive on the main roster.</p>
        </div>
      </body></html>
    HTML
    stub_team_page("T1", html)

    result = @service.fetch_team_by_name("T1")

    assert_equal "0", result["IsDisbanded"], "Team should not be detected as disbanded just because 'inactive' appears in content"
  end

  test "fetch_team_by_name normalizes team name with spaces" do
    stub_team_page("Cloud_9", team_html_fixture)

    @service.fetch_team_by_name("Cloud 9")

    assert_requested :get, "https://lol.fandom.com/wiki/Cloud_9"
  end

  test "fetch_team_by_name handles HTTP errors gracefully" do
    stub_request(:get, "https://lol.fandom.com/wiki/ErrorTeam")
      .to_return(status: 500)

    result = @service.fetch_team_by_name("ErrorTeam")

    assert_nil result
  end

  test "fetch_team_by_name handles network timeouts" do
    stub_request(:get, "https://lol.fandom.com/wiki/TimeoutTeam")
      .to_timeout

    result = @service.fetch_team_by_name("TimeoutTeam")

    assert_nil result
  end

  # ==========================================
  # fetch_team_roster tests
  # ==========================================

  test "fetch_team_roster returns array of player data" do
    stub_team_page("T1", roster_table_html_fixture)
    stub_player_page("Faker", player_html_fixture("Faker", "Lee Sang-hyeok"))
    stub_player_page("Keria", player_html_fixture("Keria", "Ryu Min-seok"))

    result = @service.fetch_team_roster("T1")

    assert_equal 2, result.length

    faker = result.find { |p| p["ID"] == "Faker" }
    assert_not_nil faker
    assert_equal "Lee Sang-hyeok", faker["Name"]
    assert_equal "Mid", faker["Role"]
    assert_equal "1", faker["IsCurrent"]

    keria = result.find { |p| p["ID"] == "Keria" }
    assert_not_nil keria
    assert_equal "Ryu Min-seok", keria["Name"]
  end

  test "fetch_team_roster returns empty array when page not found" do
    stub_request(:get, "https://lol.fandom.com/wiki/NonExistentTeam")
      .to_return(status: 404)

    result = @service.fetch_team_roster("NonExistentTeam")

    assert_equal [], result
  end

  test "fetch_team_roster returns empty array when no roster table found" do
    html = "<html><body><h1>Team Page</h1><p>No roster here</p></body></html>"
    stub_team_page("NoRoster", html)

    result = @service.fetch_team_roster("NoRoster")

    assert_equal [], result
  end

  test "fetch_team_roster filters out non-player links" do
    html = roster_table_with_noise_html_fixture
    stub_team_page("FilterTest", html)
    stub_player_page("ValidPlayer", player_html_fixture("ValidPlayer", "Real Name"))

    result = @service.fetch_team_roster("FilterTest")

    assert_equal 1, result.length
    assert_equal "ValidPlayer", result.first["ID"]
  end

  test "fetch_team_roster limits to reasonable roster size" do
    # Create HTML with 20 players
    player_rows = (1..20).map do |i|
      "<tr><td class='team-members-player'><a href='/wiki/Player#{i}'>Player#{i}</a></td><td class='team-members-role'>Mid</td></tr>"
    end.join("\n")
    html = <<~HTML
      <html><body>
        <h2 id="Active">Roster</h2>
        <table class="wikitable team-members-current">
          #{player_rows}
        </table>
      </body></html>
    HTML

    stub_team_page("BigTeam", html)
    (1..20).each do |i|
      stub_player_page("Player#{i}", player_html_fixture("Player#{i}", "Name #{i}"))
    end

    result = @service.fetch_team_roster("BigTeam")

    # Should return all 20 players (no artificial limit)
    assert_equal 20, result.length
  end

  test "fetch_team_roster handles player page parse errors" do
    stub_team_page("T1", roster_table_html_fixture)
    stub_player_page("Faker", player_html_fixture("Faker", "Lee Sang-hyeok"))
    stub_player_page("Keria", "<html><body>No infobox</body></html>")

    result = @service.fetch_team_roster("T1")

    # Should return only Faker (Keria returns nil and is filtered out)
    assert_equal 1, result.length
    assert_equal "Faker", result.first["ID"]
  end

  # ==========================================
  # Rate limiting tests
  # ==========================================

  test "enforces rate limiting between requests" do
    stub_team_page("T1", team_html_fixture)

    start_time = Time.current

    # Make two requests
    @service.fetch_team_by_name("T1")
    @service.fetch_team_by_name("T1")

    elapsed = Time.current - start_time

    # Second request should have been delayed by at least RATE_LIMIT_DELAY seconds
    assert elapsed >= LeaguepediaService::RATE_LIMIT_DELAY,
           "Expected at least #{LeaguepediaService::RATE_LIMIT_DELAY}s delay, got #{elapsed}s"
  end

  test "does not rate limit first request" do
    stub_team_page("T1", team_html_fixture)

    start_time = Time.current
    @service.fetch_team_by_name("T1")
    elapsed = Time.current - start_time

    # First request should be immediate (no delay)
    assert elapsed < 1.0, "First request should not be delayed"
  end

  # ==========================================
  # Private method behavior tests
  # ==========================================

  test "extracts team data from various infobox formats" do
    # Test different infobox HTML structures
    html = <<~HTML
      <html><body>
        <h1 class="mw-page-title-main">Test Team</h1>
        <table class="infobox">
          <tr><th>Region</th><td>North America</td></tr>
          <tr><th>Abbreviation</th><td>TST</td></tr>
          <tr><th>Website</th><td><a href="https://test.com">Website</a></td></tr>
          <tr><td><img src="//static.wikia.net/logo.png" /></td></tr>
        </table>
      </body></html>
    HTML

    stub_team_page("TestTeam", html)

    result = @service.fetch_team_by_name("TestTeam")

    assert_equal "Test Team", result["Name"]
    assert_equal "TST", result["Short"]
    assert_equal "North America", result["Region"]
    assert_equal "https://test.com", result["Website"]
    assert_match(/logo.png/, result["Image"])
  end

  test "extracts player data with age calculation from birthdate" do
    html = <<~HTML
      <html><body>
        <h1 class="mw-page-title-main">TestPlayer</h1>
        <table class="infobox">
          <tr><th>Name</th><td>Test Player Name</td></tr>
          <tr><th>Birthdate</th><td>1996-05-07</td></tr>
          <tr><th>Country</th><td>South Korea</td></tr>
          <tr><th>Nationality</th><td>Korean</td></tr>
          <tr><th>Role</th><td>Mid</td></tr>
        </table>
      </body></html>
    HTML

    stub_player_page("TestPlayer", html)

    # Need to call via fetch_team_roster to test this
    roster_html = <<~HTML
      <html><body>
        <h2 id="Active">Roster</h2>
        <table class="wikitable team-members-current">
          <tr>
            <td class="team-members-player"><a href="/wiki/TestPlayer">TestPlayer</a></td>
            <td class="team-members-role">Mid</td>
          </tr>
        </table>
      </body></html>
    HTML

    stub_team_page("Team", roster_html)

    result = @service.fetch_team_roster("Team")

    assert_equal 1, result.length
    player = result.first
    assert_equal "TestPlayer", player["ID"]
    assert_equal "Test Player Name", player["Name"]
    assert_not_nil player["Age"]
    assert player["Age"].to_i >= 25 # Born in 1996, should be at least 25
    assert_equal "1996-05-07", player["Birthdate"]
    assert_equal "Mid", player["Role"]
  end

  private

  def stub_team_page(team_name, html)
    stub_request(:get, "https://lol.fandom.com/wiki/#{team_name}")
      .to_return(status: 200, body: html, headers: { "Content-Type" => "text/html" })
  end

  def stub_player_page(player_name, html)
    stub_request(:get, "https://lol.fandom.com/wiki/#{player_name}")
      .to_return(status: 200, body: html, headers: { "Content-Type" => "text/html" })
  end

  def team_html_fixture
    <<~HTML
      <html>
      <head><title>T1 - Leaguepedia</title></head>
      <body>
        <h1 class="mw-page-title-main">T1</h1>
        <table class="infobox">
          <tr>
            <td colspan="2" style="text-align:center">
              <img src="https://static.wikia.net/lolesports/T1_logo.png" alt="T1 logo" />
            </td>
          </tr>
          <tr>
            <th>Region</th>
            <td>Korea</td>
          </tr>
          <tr>
            <th>Short</th>
            <td>T1</td>
          </tr>
          <tr>
            <th>Website</th>
            <td><a href="https://t1.gg" class="external">t1.gg</a></td>
          </tr>
        </table>
        <div class="content">
          <p>T1 is a professional League of Legends team based in South Korea.</p>
        </div>
      </body>
      </html>
    HTML
  end

  def roster_table_html_fixture
    <<~HTML
      <html>
      <body>
        <h1 class="mw-page-title-main">T1</h1>
        <h2 id="Active">Current Roster</h2>
        <table class="wikitable team-members-current">
          <thead>
            <tr><th>ID</th><th>Name</th><th>Role</th></tr>
          </thead>
          <tbody>
            <tr>
              <td class="team-members-player"><a href="/wiki/Faker">Faker</a></td>
              <td>Lee Sang-hyeok</td>
              <td class="team-members-role">Mid</td>
            </tr>
            <tr>
              <td class="team-members-player"><a href="/wiki/Keria">Keria</a></td>
              <td>Ryu Min-seok</td>
              <td class="team-members-role">Support</td>
            </tr>
          </tbody>
        </table>
      </body>
      </html>
    HTML
  end

  def roster_table_with_noise_html_fixture
    <<~HTML
      <html>
      <body>
        <h2 id="Active">Roster</h2>
        <table class="wikitable team-members-current">
          <tbody>
            <tr>
              <td class="team-members-player"><a href="/wiki/ValidPlayer">ValidPlayer</a></td>
              <td class="team-members-role">Mid</td>
            </tr>
            <tr>
              <td><a href="/wiki/File:Logo.png">File:Logo.png</a></td>
              <td><a href="/wiki/Category:Teams">Category:Teams</a></td>
              <td><a href="/wiki/2024_Season">2024 Season</a></td>
              <td><a href="/wiki/League_of_Legends">League of Legends</a></td>
            </tr>
          </tbody>
        </table>
      </body>
      </html>
    HTML
  end

  def player_html_fixture(ign, real_name, role = "Mid")
    <<~HTML
      <html>
      <head><title>#{ign} - Leaguepedia</title></head>
      <body>
        <h1 class="mw-page-title-main">#{ign}</h1>
        <table class="infobox">
          <tr>
            <th>Name</th>
            <td>#{real_name}</td>
          </tr>
          <tr>
            <th>Country</th>
            <td>South Korea</td>
          </tr>
          <tr>
            <th>Nationality</th>
            <td>Korean</td>
          </tr>
          <tr>
            <th>Birthdate</th>
            <td>1996-05-07</td>
          </tr>
          <tr>
            <th>Age</th>
            <td>28</td>
          </tr>
          <tr>
            <th>Role</th>
            <td>#{role}</td>
          </tr>
        </table>
        <div class="content">
          <p>#{ign} is a professional League of Legends player.</p>
        </div>
      </body>
      </html>
    HTML
  end
end
