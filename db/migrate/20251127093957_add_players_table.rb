class AddPlayersTable < ActiveRecord::Migration[8.0]
  def change
    create_table :players do |t|
      t.references :team, null: false, foreign_key: true
      t.string :ign
      t.string :name
      t.string :role
      t.date :contract_ends
      t.date :date_joined

      t.timestamps
    end
  end
end
