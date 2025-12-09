class CreateMovies < ActiveRecord::Migration[7.1]
  def change
    create_table :movies do |t|
      t.string :api_id
      t.string :countries
      t.string :languages
      t.integer :runtime

      t.timestamps
    end
  end
end
