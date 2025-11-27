class DropTeamsAndPlayers < ActiveRecord::Migration[8.0]
  def change
    # Drop players first (has foreign key to teams)
    drop_table :players, if_exists: true

    # Then drop teams
    drop_table :teams, if_exists: true
  end
end
