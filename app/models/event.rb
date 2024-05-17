class Event < ApplicationRecord
  validates :name, :date, presence: true

  belongs_to :creator, class_name: "User"
  has_many :requests, -> { where(requestor: "attendee") }, foreign_key: :event_id

  # We can directly use the default Rails functionality by not specifying the join_table and foreign_key.
  # Rails will automatically use the 'events_users' join table with 'event_id' and 'user_id' columns.
  # However, if we need to use a custom join table or different foreign keys, we can specify them as follows.
  has_and_belongs_to_many :attendees,
                          class_name: "User",
                          dependent: :destroy,
                          join_table: 'attended_events_attendees',
                          foreign_key: :attended_event_id,
                          association_foreign_key: :attendee_id

  enum :event_type, { public: 'public', private: 'private' }, prefix: true

  scope :past, -> { where('date < ? OR date = ? AND end_time < ?', Date.today, Date.today, Time.now) }
  scope :upcoming, -> { where('date > ? OR date = ? AND start_time > ?', Date.today, Date.today, Time.now) }
  scope :active, -> { where('date = ? AND start_time <= ? AND end_time >= ?', Date.today, Time.now, Time.now) }
  scope :others, ->(current_user){ where.not(creator: current_user) }

  accepts_nested_attributes_for :requests

  def destroy_with_associated_requests
    Request.where(event: self).destroy_all
    destroy
  end

  def start_at
    start_time.strftime('%H:%M')
  end

  def end_at
    end_time.strftime('%H:%M')
  end

  def past?
    date < Date.today || (date == Date.today && end_time < Time.now)
  end

  def upcoming?
    date > Date.today || (date == Date.today && start_time > Time.now)
  end

  def active?
    date == Date.today && start_time <= Time.now && end_time >= Time.now
  end
end
