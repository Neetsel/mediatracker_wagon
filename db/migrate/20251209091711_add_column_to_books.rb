class AddColumnToBooks < ActiveRecord::Migration[7.1]
  def change
    add_column :books, :authors, :string, array: true, default: []
  end
end
