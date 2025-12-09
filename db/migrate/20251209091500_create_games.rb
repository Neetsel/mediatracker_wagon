class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.string :api_id
      t.string :publisher
      t.integer :main_story_duration
      t.integer :main_extras_duration
      t.string :completionist_duration

      t.timestamps
    end
  end
end
