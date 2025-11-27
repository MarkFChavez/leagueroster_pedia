module Admin
  class TeamsController < BaseController
    before_action :set_team, only: [:show, :edit, :update, :destroy]
    before_action :set_base_breadcrumbs
    before_action :set_team_breadcrumbs, only: [:show, :edit, :update]

    def index
      @teams = Team.includes(:team_source).order(created_at: :desc)
      add_breadcrumb "Teams"
    end

    def show
    end

    def new
      @team = Team.new
      @team_sources = TeamSource.order(:short_name)
      add_breadcrumb "Teams", admin_teams_path
      add_breadcrumb "New"
    end

    def create
      @team = Team.new(team_params)

      if @team.save
        redirect_to admin_team_path(@team), notice: "Team was successfully created."
      else
        @team_sources = TeamSource.order(:short_name)
        add_breadcrumb "Teams", admin_teams_path
        add_breadcrumb "New"
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @team_sources = TeamSource.order(:short_name)
      add_breadcrumb "Edit"
    end

    def update
      if @team.update(team_params)
        redirect_to admin_team_path(@team), notice: "Team was successfully updated."
      else
        @team_sources = TeamSource.order(:short_name)
        add_breadcrumb "Edit"
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @team.destroy
      redirect_to admin_teams_path, notice: "Team was successfully deleted."
    end

    private

    def set_base_breadcrumbs
      add_breadcrumb "Admin", admin_root_path
    end

    def set_team_breadcrumbs
      add_breadcrumb "Teams", admin_teams_path
      add_breadcrumb "Team ##{@team.id}"
    end

    def set_team
      @team = Team.find(params[:id])
    end

    def team_params
      params.require(:team).permit(:team_source_id, :org_location, :region)
    end
  end
end
