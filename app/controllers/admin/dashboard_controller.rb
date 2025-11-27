module Admin
  class DashboardController < BaseController
    def index
      add_breadcrumb "Admin", admin_root_path

      # Statistics
      @team_sources_count = TeamSource.count
      @teams_count = Team.count
      @players_count = Player.count
      @last_synced = TeamSource.where.not(last_synced_at: nil).order(last_synced_at: :desc).first
    end
  end
end
