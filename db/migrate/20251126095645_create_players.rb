class CreatePlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :players do |t|
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
  end
end
