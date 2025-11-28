module Admin
  class TeamSourcesController < BaseController
    before_action :set_team_source, only: [:show, :edit, :update, :destroy, :sync]
    before_action :set_base_breadcrumbs
    before_action :set_team_source_breadcrumbs, only: [:show, :edit, :update]

    def index
      @team_sources = TeamSource.order(created_at: :desc)

      if params[:q].present?
        search_term = "%#{params[:q]}%"
        @team_sources = @team_sources.where(
          "short_name LIKE ? OR long_name LIKE ? OR external_team_url LIKE ?",
          search_term, search_term, search_term
        )
      end

      @team_sources = @team_sources.page(params[:page])

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

    def sync
      begin
        # Set timeout to prevent long-running requests
        Timeout.timeout(30) do
          @team_source.sync

          # Get sync results for feedback
          team = @team_source.teams.first
          player_count = team&.players&.count || 0

          redirect_to admin_team_source_path(@team_source),
                      notice: "Successfully synced #{@team_source.short_name}. Fetched #{player_count} players."
        end
      rescue Timeout::Error
        redirect_to admin_team_source_path(@team_source),
                    alert: "Sync timed out after 30 seconds. The source may be slow or unavailable."
      rescue HTTParty::Error, SocketError => e
        redirect_to admin_team_source_path(@team_source),
                    alert: "Network error during sync: #{e.message}"
      rescue StandardError => e
        redirect_to admin_team_source_path(@team_source),
                    alert: "Sync failed: #{e.message}"
      end
    end

    def sync_all
      team_sources = TeamSource.all
      team_sources.each do |team_source|
        TeamSyncJob.perform_later(team_source.id)
      end

      redirect_to admin_team_sources_path,
                  notice: "Syncing #{team_sources.count} team sources in the background. Check the Jobs dashboard for progress."
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
