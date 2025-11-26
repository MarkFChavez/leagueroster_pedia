namespace :sync_details do
  desc "Sync a single team's details and roster from Leaguepedia (e.g., bin/rails sync_details:run[T1])"
  task :run, [:team_name] => :environment do |t, args|
    team_name = args[:team_name]

    unless team_name
      puts "❌ Error: Please provide a team name"
      puts "Usage: bin/rails sync_details:run[TEAM_NAME]"
      puts "Examples:"
      puts "  bin/rails sync_details:run[T1]"
      puts "  bin/rails sync_details:run[G2]"
      puts "  bin/rails \"sync_details:run[Hanwha Life Esports]\""
      exit
    end

    puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    puts "  Syncing team: #{team_name}"
    puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    puts ""

    # Run the sync job synchronously
    SyncLeaguepediaDataJob.perform_now(team_name)

    puts ""
    puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    puts "  ✓ Sync complete!"
    puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    puts ""
    puts "Visit http://localhost:3000 to view the team"
  rescue StandardError => e
    puts ""
    puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    puts "  ❌ Error: #{e.message}"
    puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    puts ""
    puts "Common issues:"
    puts "  - Check team name spelling (case-sensitive)"
    puts "  - Rate limited: wait a few minutes and try again"
    puts "  - Team might not exist on Leaguepedia"
  end
end
