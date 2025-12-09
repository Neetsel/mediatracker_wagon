class CreateMedia < ActiveRecord::Migration[7.1]
  def change
    create_table :media do |t|
      t.string :title
      t.string :description
      t.date :release_date
      t.string :year
      t.string :poster_url
      t.belongs_to :sub_media, polymorphic: true

      t.timestamps
    end
  end
end
