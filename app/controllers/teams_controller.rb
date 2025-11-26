class TeamsController < ApplicationController
  def index
    @teams = Team.where(is_disbanded: [false, nil])
                 .includes(:players)
                 .order(:region, :name)
  end

  def show
    @team = Team.includes(:players).find(params[:id])
    @current_players = @team.players.where(is_current: true).ordered_by_role
  end
end
