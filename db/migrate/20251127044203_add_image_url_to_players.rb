class AddImageUrlToPlayers < ActiveRecord::Migration[8.0]
  def change
    add_column :players, :image_url, :string
  end
end
