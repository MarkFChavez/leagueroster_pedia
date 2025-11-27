module Admin
  class TeamSourcesController < BaseController
    before_action :set_team_source, only: [:show, :edit, :update, :destroy]
    before_action :set_base_breadcrumbs
    before_action :set_team_source_breadcrumbs, only: [:show, :edit, :update]

    def index
      @team_sources = TeamSource.order(created_at: :desc)
      add_breadcrumb "Team Sources"
    end

    def show
    end

    def new
      @team_source = TeamSource.new
      add_breadcrumb "Team Sources", admin_team_sources_path
      add_breadcrumb "New"
    end

    def create
      @team_source = TeamSource.new(team_source_params)

      if @team_source.save
        redirect_to admin_team_source_path(@team_source), notice: "Team source was successfully created."
      else
        add_breadcrumb "Team Sources", admin_team_sources_path
        add_breadcrumb "New"
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      add_breadcrumb "Edit"
    end

    def update
      if @team_source.update(team_source_params)
        redirect_to admin_team_source_path(@team_source), notice: "Team source was successfully updated."
      else
        add_breadcrumb "Edit"
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @team_source.destroy
      redirect_to admin_team_sources_path, notice: "Team source was successfully deleted."
    end

    private

    def set_base_breadcrumbs
      add_breadcrumb "Admin", admin_root_path
    end

    def set_team_source_breadcrumbs
      add_breadcrumb "Team Sources", admin_team_sources_path
      add_breadcrumb @team_source.short_name
    end

    def set_team_source
      @team_source = TeamSource.find(params[:id])
    end

    def team_source_params
      params.require(:team_source).permit(:short_name, :long_name, :external_team_url, :last_synced_at)
    end
  end
end
