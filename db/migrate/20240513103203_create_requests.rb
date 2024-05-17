class CreateRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :requests do |t|
      t.belongs_to :event, null: false, foreign_key: true
      t.belongs_to :attendee, null: false, foreign_key: true, foreign_key: { to_table: :users }
      t.string :status, default: 'pending'
      t.string :requestor

      t.timestamps
    end
  end
end
