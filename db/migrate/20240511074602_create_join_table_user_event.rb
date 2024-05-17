class CreateJoinTableUserEvent < ActiveRecord::Migration[7.0]
  def change
    create_join_table :attendees, :attended_events do |t|
      # Added uniqueness to ensure that a user cannot join the same event more than once.
      t.index [:attendee_id, :attended_event_id], unique: true, name: 'index_events_users_on_attendee_id_and_attended_event_id'
    end
  end
end
