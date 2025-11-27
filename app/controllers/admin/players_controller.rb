module Admin
  class PlayersController < BaseController
    before_action :set_player, only: [:show, :edit, :update, :destroy]
    before_action :set_base_breadcrumbs
    before_action :set_player_breadcrumbs, only: [:show, :edit, :update]

    def index
      @players = Player.includes(:team).order(created_at: :desc)
      add_breadcrumb "Players"
    end

    def show
    end

    def new
      @player = Player.new
      @teams = Team.order(:id)
      add_breadcrumb "Players", admin_players_path
      add_breadcrumb "New"
    end

    def create
      @player = Player.new(player_params)

      if @player.save
        redirect_to admin_player_path(@player), notice: "Player was successfully created."
      else
        @teams = Team.order(:id)
        add_breadcrumb "Players", admin_players_path
        add_breadcrumb "New"
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @teams = Team.order(:id)
      add_breadcrumb "Edit"
    end

    def update
      if @player.update(player_params)
        redirect_to admin_player_path(@player), notice: "Player was successfully updated."
      else
        @teams = Team.order(:id)
        add_breadcrumb "Edit"
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @player.destroy
      redirect_to admin_players_path, notice: "Player was successfully deleted."
    end

    private

    def set_base_breadcrumbs
      add_breadcrumb "Admin", admin_root_path
    end

    def set_player_breadcrumbs
      add_breadcrumb "Players", admin_players_path
      add_breadcrumb @player.ign
    end

    def set_player
      @player = Player.find(params[:id])
    end

    def player_params
      params.require(:player).permit(:team_id, :ign, :role)
    end
  end
end
