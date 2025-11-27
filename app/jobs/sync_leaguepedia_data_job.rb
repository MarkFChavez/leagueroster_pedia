class SyncLeaguepediaDataJob < ApplicationJob
  queue_as :default

  def perform(team_name)
    service = LeaguepediaService.new

    # Fetch team data
    Rails.logger.info("Fetching data for team: #{team_name}...")
    team_data = service.fetch_team_by_name(team_name)

    unless team_data
      Rails.logger.error("Team '#{team_name}' not found on Leaguepedia")
      return
    end

    # Skip disbanded teams
    if team_data['IsDisbanded'] == '1'
      Rails.logger.info("Team '#{team_name}' is disbanded, skipping...")
      return
    end

    # Save team data
    team = Team.find_or_initialize_by(name: team_data['Name'])
    team.update!(
      short_name: team_data['Short'],
      region: team_data['Region'],
      logo_url: team_data['Image'],
      website: team_data['Website'],
      is_disbanded: false,
      last_synced_at: Time.current
    )

    Rails.logger.info("Team synced: #{team.name} (#{team.region})")

    # Fetch and save roster data
    Rails.logger.info("Fetching roster for #{team.name}...")
    roster_data = service.fetch_team_roster(team.name)

    # Mark all current players as not current before updating
    team.players.update_all(is_current: false)

    roster_data.each do |player_data|
      player = team.players.find_or_initialize_by(ign: player_data['ID'])
      is_new = player.new_record?

      player.assign_attributes(
        real_name: player_data['Name'],
        country: player_data['Country'],
        nationality: player_data['Nationality'],
        age: player_data['Age']&.to_i,
        birthdate: parse_date(player_data['Birthdate']),
        role: player_data['Role'],
        date_joined: parse_date(player_data['DateJoin']),
        is_current: player_data['IsCurrent'] == '1',
        last_synced_at: Time.current
      )

      player.save!
      action = is_new ? "Created" : "Updated"
      Rails.logger.info("  #{action} player: #{player.ign} - #{player.real_name} (#{player.role})")
    end

    Rails.logger.info("✓ Successfully synced #{team.name} with #{roster_data.count} players")
  end

  private

  def parse_date(date_string)
    return nil if date_string.blank?

    Date.parse(date_string)
  rescue ArgumentError
    nil
  end
end
