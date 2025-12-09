class AddColumnToMovies < ActiveRecord::Migration[7.1]
  def change
    add_column :movies, :directors, :string, array: true, default: []
    add_column :movies, :writers, :string, array: true, default: []
    add_column :movies, :actors, :string, array: true, default: []
  end
end
