class AddNameToTeams < ActiveRecord::Migration[8.0]
  def change
    add_column :teams, :name, :string
    add_column :teams, :short_name, :string
    add_index :teams, :name
  end
end
