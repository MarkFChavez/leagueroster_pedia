class LeaguepediaService
  include HTTParty
  base_uri 'https://lol.fandom.com'

  RATE_LIMIT_DELAY = 2.5 # seconds between requests

  def initialize
    @last_request_time = nil
  end

  # Fetch a specific team by name (scrapes team wiki page)
  def fetch_team_by_name(team_name)
    html = fetch_page("/wiki/#{normalize_page_name(team_name)}")
    return nil unless html

    parse_team_page(html, team_name)
  rescue StandardError => e
    Rails.logger.error("Error fetching team #{team_name}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    nil
  end

  # Fetch current roster for a specific team (scrapes team page + individual player pages)
  def fetch_team_roster(team_name)
    html = fetch_page("/wiki/#{normalize_page_name(team_name)}")
    return [] unless html

    player_names = extract_roster_player_names(html)
    return [] if player_names.empty?

    Rails.logger.info("Found #{player_names.count} players in roster: #{player_names.join(', ')}")

    player_names.map do |player_name|
      fetch_player_data(player_name)
    end.compact
  rescue StandardError => e
    Rails.logger.error("Error fetching roster for #{team_name}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    []
  end

  private

  # Fetch a page with rate limiting
  def fetch_page(path)
    enforce_rate_limit

    response = self.class.get(path, {
      follow_redirects: true,
      headers: {
        'User-Agent' => 'LeagueRosterPedia/1.0 (Educational Project)'
      }
    })

    @last_request_time = Time.current

    if response.code == 200
      response.body
    elsif response.code == 404
      Rails.logger.warn("Page not found: #{path}")
      nil
    else
      Rails.logger.error("HTTP error #{response.code} for #{path}")
      nil
    end
  rescue Net::ReadTimeout, Net::OpenTimeout => e
    Rails.logger.error("Timeout fetching #{path}: #{e.message}")
    nil
  end

  # Enforce rate limiting between requests
  def enforce_rate_limit
    return unless @last_request_time

    elapsed = Time.current - @last_request_time
    if elapsed < RATE_LIMIT_DELAY
      sleep_time = RATE_LIMIT_DELAY - elapsed
      Rails.logger.debug("Rate limiting: sleeping #{sleep_time.round(2)}s")
      sleep(sleep_time)
    end
  end

  # Parse team wiki page to extract team data
  def parse_team_page(html, team_name)
    doc = Nokogiri::HTML(html)

    # Find the infobox (usually has class 'infobox' or similar)
    infobox = doc.at_css('.infobox, .portable-infobox')

    unless infobox
      Rails.logger.warn("No infobox found for team #{team_name}")
      return nil
    end

    # Priority order for extracting full team name:
    # 1. Check for .infobox-title element (most reliable for full name)
    full_name = infobox.at_css('.infobox-title')&.text&.strip

    # 2. Look for common infobox fields that contain the full team name
    full_name ||= extract_infobox_value(infobox, ['Name', 'Full Name', 'Team Name', 'Official Name'])

    # 3. Fall back to page title
    full_name ||= doc.at_css('h1.mw-page-title-main')&.text&.strip

    # 4. Last resort: use the input team name
    full_name ||= team_name

    # Extract data from infobox rows
    {
      'Name' => full_name,
      'Short' => extract_infobox_value(infobox, ['Short', 'Abbreviation', 'Tag']) || team_name,
      'Region' => extract_infobox_value(infobox, ['Region']),
      'Image' => extract_team_logo(infobox),
      'Website' => extract_infobox_link(infobox, ['Website', 'Web']),
      'IsDisbanded' => detect_disbanded(doc) ? '1' : '0'
    }
  end

  # Extract roster player names from team page
  def extract_roster_player_names(html)
    doc = Nokogiri::HTML(html)
    player_names = []

    # First, try to find the Active roster table (most reliable)
    # This table has class 'team-members-current' and contains only active players
    roster_table = doc.at_css('table.team-members-current')

    # Fallback: Look for the "Active" section heading and get the table after it
    unless roster_table
      active_heading = doc.at_css('#Active')
      if active_heading
        # Find the next table after the Active heading
        roster_table = active_heading.parent.next_element
        roster_table = roster_table.next_element until roster_table.nil? || roster_table.name == 'table'
      end
    end

    # Another fallback: Look for any table with "active" or "current" in class/id
    roster_table ||= doc.at_css('table[class*="team-members"]')

    return [] unless roster_table

    # Extract player names from the table rows
    # Each player is in a <td> with class "team-members-player"
    roster_table.css('td.team-members-player').each do |player_cell|
      link = player_cell.at_css('a[href^="/wiki/"]')
      next unless link

      href = link['href']

      # Skip non-player pages (categories, files, special pages, etc.)
      next if href.match?(/wiki\/(File|Category|Special|Template|User|Talk|Help|Project):/)

      # Extract player name from URL
      player_name = href.sub('/wiki/', '')
      next if player_name.blank?

      player_names << player_name unless player_names.include?(player_name)
    end

    # Also check the role column to filter out non-players (coaches, staff, etc.)
    # If we didn't find any players with the above method, fall back to more generic extraction
    if player_names.empty?
      roster_table.css('tr').each do |row|
        # Check if this row has a role indicator (player roles have role sprites)
        role_cell = row.at_css('td.team-members-role')
        next unless role_cell

        # Check if role is a player role (Top, Jungle, Mid, Bot, Support)
        role_text = role_cell.text.strip
        next unless role_text.match?(/Top|Jungle|Mid|Bot|Support/i)

        # Extract player link from this row
        player_link = row.at_css('td.team-members-player a[href^="/wiki/"]')
        next unless player_link

        href = player_link['href']
        next if href.match?(/wiki\/(File|Category|Special|Template|User|Talk|Help|Project):/)

        player_name = href.sub('/wiki/', '')
        next if player_name.blank?

        player_names << player_name unless player_names.include?(player_name)
      end
    end

    Rails.logger.info("Extracted #{player_names.count} active players: #{player_names.join(', ')}")
    player_names
  end

  # Fetch and parse individual player page
  def fetch_player_data(player_name)
    html = fetch_page("/wiki/#{player_name}")
    return nil unless html

    doc = Nokogiri::HTML(html)
    infobox = doc.at_css('.infobox, .portable-infobox')

    unless infobox
      Rails.logger.warn("No infobox found for player #{player_name}")
      return nil
    end

    # Extract IGN from page title or infobox
    ign = doc.at_css('h1.mw-page-title-main')&.text&.strip || player_name.gsub('_', ' ')

    {
      'ID' => ign,
      'Name' => extract_infobox_value(infobox, ['Name', 'Real Name', 'Birth Name']),
      'Country' => extract_infobox_value(infobox, ['Country', 'Residency']),
      'Nationality' => extract_infobox_value(infobox, ['Nationality', 'Country']),
      'Age' => extract_age(infobox),
      'Birthdate' => extract_infobox_value(infobox, ['Birth', 'Birthdate', 'Date of Birth', 'Born']),
      'Role' => extract_infobox_value(infobox, ['Role', 'Position', 'Main Role']),
      'DateJoin' => nil, # Not easily available from player page
      'IsCurrent' => '1' # Assume current since we're scraping from current roster
    }
  rescue StandardError => e
    Rails.logger.error("Error parsing player #{player_name}: #{e.message}")
    nil
  end

  # Extract value from infobox by label
  def extract_infobox_value(infobox, labels)
    labels.each do |label|
      # Try different infobox formats

      # Format 1: <tr><th>Label</th><td>Value</td></tr>
      row = infobox.at_css("tr:has(th:contains('#{label}'))")
      if row
        value = row.at_css('td')&.text&.strip
        return deduplicate_text(value) if value.present?
      end

      # Format 2: <div data-source="label"><div class="pi-data-value">Value</div></div>
      data_item = infobox.at_css("[data-source*='#{label.downcase.gsub(' ', '')}']")
      if data_item
        value = data_item.at_css('.pi-data-value, .pi-font')&.text&.strip
        return deduplicate_text(value) if value.present?
      end

      # Format 3: <div class="infobox-label">Label</div><div class="infobox-data">Value</div>
      label_div = infobox.css('.infobox-label, .pi-data-label').find { |el| el.text.strip.match?(/#{label}/i) }
      if label_div
        value = label_div.next_element&.text&.strip
        return deduplicate_text(value) if value.present?
      end
    end

    nil
  end

  # Deduplicate text that may have been concatenated from nested HTML elements
  # e.g., "EMEAEMEA" -> "EMEA", "KRKorea" -> "KR"
  def deduplicate_text(text)
    return text unless text.present? && text.length.even?

    half = text.length / 2
    first_half = text[0...half]
    second_half = text[half..-1]

    # If first half equals second half, it's duplicated
    first_half == second_half ? first_half : text
  end

  # Extract team logo URL from infobox
  def extract_team_logo(infobox)
    img = infobox.at_css('img')
    return nil unless img

    src = img['src'] || img['data-src']
    return nil unless src

    # Convert to absolute URL if needed
    src.start_with?('http') ? src : "https:#{src}"
  end

  # Extract link URL from infobox
  def extract_infobox_link(infobox, labels)
    labels.each do |label|
      row = infobox.at_css("tr:has(th:contains('#{label}'))")
      next unless row

      link = row.at_css('td a')
      return link['href'] if link && link['href']
    end

    nil
  end

  # Detect if team is disbanded from page content
  def detect_disbanded(doc)
    # Check infobox for explicit disbanded/inactive status
    infobox = doc.at_css('.infobox, .portable-infobox')

    if infobox
      # Look for status field indicating disbanded/inactive
      status = extract_infobox_value(infobox, ['Status', 'Active'])
      if status.present?
        status_lower = status.downcase
        return true if status_lower.include?('disbanded') ||
                       status_lower.include?('inactive') ||
                       status_lower.include?('dissolved')
      end
    end

    # Check for disbanded category or explicit disbanded notice
    # Only check specific elements, not entire page content to avoid false positives
    page_categories = doc.css('.page-header__categories, .page-footer__categories')
    categories_text = page_categories.map(&:text).join(' ').downcase

    categories_text.include?('disbanded teams') ||
      categories_text.include?('inactive teams')
  end

  # Extract age from infobox (or calculate from birthdate)
  def extract_age(infobox)
    age_text = extract_infobox_value(infobox, ['Age'])
    return age_text if age_text.present?

    # Try to calculate from birthdate
    birthdate_text = extract_infobox_value(infobox, ['Birth', 'Birthdate', 'Born'])
    return nil unless birthdate_text

    begin
      birthdate = Date.parse(birthdate_text)
      ((Time.current - birthdate.to_time) / 1.year).floor.to_s
    rescue ArgumentError
      nil
    end
  end

  # Normalize page name for URL (replace spaces with underscores)
  def normalize_page_name(name)
    name.strip.gsub(' ', '_')
  end
end
