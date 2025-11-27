module Admin
  class TeamsController < BaseController
    before_action :set_team, only: [:show]
    before_action :set_base_breadcrumbs
    before_action :set_team_breadcrumbs, only: [:show]

    def index
      @teams = Team.includes(:team_source).order(created_at: :desc)

      if params[:q].present?
        search_term = "%#{params[:q]}%"
        @teams = @teams.joins(:team_source).where(
          "team_sources.short_name LIKE ? OR team_sources.long_name LIKE ? OR teams.org_location LIKE ? OR teams.region LIKE ?",
          search_term, search_term, search_term, search_term
        )
      end

      @teams = @teams.page(params[:page])

      add_breadcrumb "Teams"
    end

    def show
    end

    private

    def set_base_breadcrumbs
      add_breadcrumb "Admin", admin_root_path
    end

    def set_team_breadcrumbs
      add_breadcrumb "Teams", admin_teams_path
      add_breadcrumb "##{@team.id}"
    end

    def set_team
      @team = Team.find(params[:id])
    end
  end
end
