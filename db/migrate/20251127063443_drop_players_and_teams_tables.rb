class DropPlayersAndTeamsTables < ActiveRecord::Migration[8.0]
  def change
    # Drop players first (has foreign key to teams)
    drop_table :players, if_exists: true do |t|
      t.string :ign
      t.string :real_name
      t.string :country
      t.string :nationality
      t.integer :age
      t.date :birthdate
      t.string :role
      t.references :team, null: false, foreign_key: true
      t.date :date_joined
      t.boolean :is_current
      t.text :previous_teams
      t.datetime :last_synced_at
      t.timestamps
    end

    # Then drop teams
    drop_table :teams, if_exists: true do |t|
      t.string :name
      t.string :short_name
      t.string :region
      t.string :logo_url
      t.string :website
      t.boolean :is_disbanded
      t.datetime :last_synced_at
      t.string :leaguepedia_team_path
      t.timestamps
    end
  end
end
