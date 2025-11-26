class TeamsController < ApplicationController
  def index
    @teams_by_region = Team.where(is_disbanded: [false, nil])
                           .includes(:players)
                           .order(:region, :name)
                           .group_by(&:region)
  end

  def show
    @team = Team.includes(:players).find(params[:id])
    @current_players = @team.players.where(is_current: true).order(:role)
  end
end
