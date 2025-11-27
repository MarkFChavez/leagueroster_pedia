class RecreatePlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :players do |t|
      t.references :team, null: false, foreign_key: true
      t.string :ign
      t.string :role

      t.timestamps
    end
  end
end
