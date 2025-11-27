module Admin
  class PlayersController < BaseController
    before_action :set_player, only: [:show]
    before_action :set_base_breadcrumbs
    before_action :set_player_breadcrumbs, only: [:show]

    def index
      @players = Player.includes(:team => :team_source).order(created_at: :desc)

      if params[:q].present?
        search_term = "%#{params[:q]}%"
        @players = @players.joins(team: :team_source).where(
          "players.ign LIKE ? OR players.name LIKE ? OR players.role LIKE ? OR team_sources.short_name LIKE ?",
          search_term, search_term, search_term, search_term
        )
      end

      @players = @players.page(params[:page])

      add_breadcrumb "Players"
    end

    def show
    end

    private

    def set_base_breadcrumbs
      add_breadcrumb "Admin", admin_root_path
    end

    def set_player_breadcrumbs
      add_breadcrumb "Players", admin_players_path
      add_breadcrumb @player.ign || "##{@player.id}"
    end

    def set_player
      @player = Player.find(params[:id])
    end
  end
end
