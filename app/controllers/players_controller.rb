class PlayersController < ApplicationController
  def search
    @query = params[:q].to_s.strip

    if @query.present?
      @players = Player.where(is_current: true)
                      .where("LOWER(ign) LIKE ?", "%#{@query.downcase}%")
                      .includes(:team)
                      .limit(10)
    else
      @players = []
    end

    render partial: "players/search_results", locals: { players: @players, query: @query }
  end
end
