class CreateTeamSources < ActiveRecord::Migration[8.0]
  def change
    create_table :team_sources do |t|
      t.string :short_name
      t.string :long_name
      t.string :external_team_url
      t.datetime :last_synced_at

      t.timestamps
    end

    add_index :team_sources, :short_name, unique: true
  end
end
