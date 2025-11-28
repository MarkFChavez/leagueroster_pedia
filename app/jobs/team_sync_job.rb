class TeamSyncJob < ApplicationJob
  queue_as :default

  def perform(team_source_id)
    team_source = TeamSource.find(team_source_id)
    team_source.sync
  end
end
