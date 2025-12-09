class AddColumnToMedia < ActiveRecord::Migration[7.1]
  def change
    add_column :media, :genres, :string, array: true, default: []

  end
end
