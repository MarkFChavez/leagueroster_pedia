class TeamsController < ApplicationController
  def show
    @team = Team.includes(:team_source, :players).find(params[:id])
  end
end
