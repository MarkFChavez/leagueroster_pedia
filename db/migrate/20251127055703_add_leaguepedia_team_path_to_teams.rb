class AddLeaguepediaTeamPathToTeams < ActiveRecord::Migration[8.0]
  def change
    add_column :teams, :leaguepedia_team_path, :string
  end
end
