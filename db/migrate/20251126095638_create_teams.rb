class CreateTeams < ActiveRecord::Migration[8.0]
  def change
    create_table :teams do |t|
      t.string :name
      t.string :short_name
      t.string :region
      t.string :logo_url
      t.string :website
      t.boolean :is_disbanded
      t.datetime :last_synced_at

      t.timestamps
    end
  end
end
