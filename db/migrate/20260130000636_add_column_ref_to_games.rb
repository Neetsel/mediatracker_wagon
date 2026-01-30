class AddColumnRefToGames < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :developers_ref, :string, array: true, default: []
    add_column :games, :publishers_ref, :string, array: true, default: []
    add_column :games, :platforms_ref, :string, array: true, default: []
  end
end
