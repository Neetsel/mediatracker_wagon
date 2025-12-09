class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :books do |t|
      t.string :isbn
      t.string :publisher
      t.integer :amount_pages

      t.timestamps
    end
  end
end
