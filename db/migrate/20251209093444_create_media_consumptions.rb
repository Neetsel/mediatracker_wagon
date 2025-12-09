class CreateMediaConsumptions < ActiveRecord::Migration[7.1]
  def change
    create_table :media_consumptions do |t|
      t.string :status
      t.date :consumption_date
      t.references :collection, null: false, foreign_key: true

      t.timestamps
    end
  end
end
