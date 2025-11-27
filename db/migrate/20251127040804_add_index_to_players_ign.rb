class AddIndexToPlayersIgn < ActiveRecord::Migration[8.0]
  def change
    add_index :players, :ign
  end
end
