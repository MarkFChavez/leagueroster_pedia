class ScheduledTeamSyncJob < ApplicationJob
  queue_as :default

  def perform
    return unless should_sync_this_week?

    TeamSource.find_each do |team_source|
      TeamSyncJob.perform_later(team_source.id)
    end
  end

  private

  def should_sync_this_week?
    month = Date.current.month

    # Weekly during offseason (Nov-Jan)
    return true if month.in?([ 11, 12, 1 ])

    # Monthly during regular season (first week only)
    Date.current.day <= 7
  end
end
