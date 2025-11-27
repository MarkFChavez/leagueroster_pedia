class AddTeamsBack < ActiveRecord::Migration[8.0]
  def change
    create_table :teams do |t|
      t.references :team_source, null: false, foreign_key: true
      t.string :org_location
      t.string :region

      t.timestamps
    end
  end
end
