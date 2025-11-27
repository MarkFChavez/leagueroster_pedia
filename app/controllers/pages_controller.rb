class PagesController < ApplicationController
  def index
    # Fetch all teams with their associations for efficient loading
    teams = Team.includes(:team_source, :players).order('team_sources.short_name')

    # Group teams by region for Regional Leagues display
    # This structure allows easy switching to other design concepts
    @teams_by_region = teams.group_by { |team| team.region.presence || "Other" }

    # Sort regions by common esports league order
    region_order = ["LCK", "LPL", "LEC", "LCS", "PCS", "VCS", "CBLOL", "LJL", "LLA", "Other"]
    @teams_by_region = @teams_by_region.sort_by { |region, _| region_order.index(region) || 999 }.to_h

    # Also provide flat list for other potential layouts
    @all_teams = teams
  end
end
