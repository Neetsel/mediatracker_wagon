class AddColumnToBook < ActiveRecord::Migration[7.1]
  def change
    add_column :books, :work_id, :string
    add_column :books, :book_id, :string
  end
end
