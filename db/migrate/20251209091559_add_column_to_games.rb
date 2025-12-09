class AddColumnToGames < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :developers, :string, array: true, default: []
    add_column :games, :platforms, :string, array: true, default: []
  end
end
