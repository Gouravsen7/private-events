class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :events, class_name: "Event", dependent: :destroy, foreign_key: :creator_id
  has_many :owner_requests, through: :events, source: :requests
  has_many :attendee_requests, -> { where(requestor: "owner") }, class_name: 'Request', dependent: :destroy, foreign_key: :attendee_id

  # We can directly use the default Rails functionality by not specifying the join_table and foreign_key.
  # Rails will automatically use the 'events_users' join table with 'event_id' and 'user_id' columns.
  # However, if we need to use a custom join table or different foreign keys, we can specify them as follows.
  has_and_belongs_to_many :attended_events,
                          class_name: "Event",
                          dependent: :destroy,
                          join_table: 'attended_events_attendees',
                          foreign_key: :attendee_id,
                          association_foreign_key: :attended_event_id
end
