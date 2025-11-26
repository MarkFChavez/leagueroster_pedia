# frozen_string_literal: true

namespace :test_scraping do
  desc "Test the web scraping service with a real team (use with caution - hits live site)"
  task :run, [:team_name] => :environment do |t, args|
    team_name = args[:team_name] || "T1"

    puts "=" * 80
    puts "Testing LeaguepediaService with team: #{team_name}"
    puts "=" * 80
    puts ""

    service = LeaguepediaService.new

    # Test fetch_team_by_name
    puts "1. Fetching team data..."
    team_data = service.fetch_team_by_name(team_name)

    if team_data
      puts "SUCCESS: Team data retrieved"
      puts ""
      team_data.each do |key, value|
        puts "  #{key.ljust(15)}: #{value}"
      end
      puts ""
    else
      puts "ERROR: Could not fetch team data"
      exit 1
    end

    # Test fetch_team_roster
    puts "2. Fetching roster data..."
    puts "(This will take a while due to rate limiting...)"
    puts ""

    roster_data = service.fetch_team_roster(team_name)

    if roster_data.any?
      puts "SUCCESS: Found #{roster_data.count} players"
      puts ""

      roster_data.each_with_index do |player, index|
        puts "Player #{index + 1}:"
        player.each do |key, value|
          puts "  #{key.ljust(15)}: #{value}" if value.present?
        end
        puts ""
      end
    else
      puts "WARNING: No roster data found"
    end

    puts "=" * 80
    puts "Test complete!"
    puts "=" * 80
  end
end
