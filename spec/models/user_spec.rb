require 'rails_helper'

RSpec.describe User, type: :model do
  describe "associations" do
    it { should have_many(:events).class_name('Event').dependent(:destroy).with_foreign_key(:creator_id) }
    it { should have_many(:owner_requests).through(:events).source(:requests) }

    it do
      should have_many(:attendee_requests)
        .conditions(requestor: "owner")
        .class_name('Request')
        .dependent(:destroy)
        .with_foreign_key(:attendee_id)
    end

    it do
      should have_and_belong_to_many(:attended_events)
        .class_name('Event').dependent(:destroy)
        .with_foreign_key(:attendee_id)
        .join_table('attended_events_attendees')
    end
  end
end
