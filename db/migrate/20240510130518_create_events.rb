class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.string :name
      t.string :location
      t.time :start_time
      t.time :end_time
      t.references :creator, null: false, foreign_key: true, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
