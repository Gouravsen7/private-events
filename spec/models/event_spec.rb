require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:date) }
  end

  describe 'associations' do
    it { should belong_to(:creator).class_name('User') }
    it { should have_many(:requests).conditions(requestor: "attendee").class_name('Request').with_foreign_key(:event_id) }
    it { should have_and_belong_to_many(:attendees).class_name('User').dependent(:destroy).join_table('attended_events_attendees') }
  end

  describe 'enums' do
    it do
      should define_enum_for(:event_type)
        .with_values(public: 'public', private: 'private')
        .backed_by_column_of_type(:string)
        .with_prefix(true)
    end
  end

  describe 'scopes' do
    describe 'past' do
      it 'includes events with date before today' do
        past_event = create(:event, date: Date.yesterday, end_time: Time.now - 1.hour)
        expect(Event.past).to include(past_event)
      end

      it 'excludes events with date today and end time after now' do
        current_event = create(:event, date: Date.today, end_time: Time.now + 1.hour)
        expect(Event.past).not_to include(current_event)
      end
    end

    describe 'active' do
      it 'includes events with current date and time' do
        active_event = create(:event, date: Date.today, start_time: Time.now - 1.hour, end_time: Time.now + 1.hour)
        expect(Event.active).to include(active_event)
      end

      it 'excludes events with date today and end time after now' do
        current_event = create(:event, date: Date.tomorrow, end_time: Time.now + 1.hour)
        expect(Event.active).not_to include(current_event)
      end
    end

    describe 'upcoming' do
      it 'includes events with date before today or with end time before now' do
        upcoming_event = create(:event, date: Date.tomorrow, end_time: Time.now - 1.hour)
        expect(Event.upcoming).to include(upcoming_event)
      end

      it 'excludes events with date today and end time after now' do
        current_event = create(:event, date: Date.yesterday, end_time: Time.now + 1.hour)
        expect(Event.upcoming).not_to include(current_event)
      end
    end
  end

  describe 'methods' do
    let(:event) { create(:event, date: Date.today, start_time: Time.current - 1.hour, end_time: Time.current + 1.hour) }

    describe '#destroy_with_associated_requests' do
      it 'destroys associated requests and then the event itself' do
        create(:request, event: event)
        expect { event.destroy_with_associated_requests }.to change { Request.count }.by(-1).and change { Event.count }.by(-1)
      end
    end

    describe '#start_at' do
      it 'returns the formatted start time' do
        expect(event.start_at).to eq((Time.current - 1.hour).strftime('%H:%M'))
      end
    end

    describe '#end_at' do
      it 'returns the formatted end time' do
        expect(event.end_at).to eq((Time.current + 1.hour).strftime('%H:%M'))
      end
    end

    describe '#past?' do
      it 'returns true if event is in the past' do
        past_event = create(:event, date: Date.yesterday, end_time: Time.current - 1.hour)
        expect(past_event.past?).to be_truthy
      end

      it 'returns false if event is not in the past' do
        future_event = create(:event, date: Date.tomorrow)
        expect(future_event.past?).to be_falsy
      end
    end

    describe '#upcoming?' do
      it 'returns true if event is upcoming' do
        upcoming_event = create(:event, date: Date.tomorrow, end_time: Time.current - 1.hour)
        expect(upcoming_event.upcoming?).to be_truthy
      end

      it 'returns false if event is not in the upcoming' do
        past_event = create(:event, date: Date.yesterday)
        expect(past_event.upcoming?).to be_falsy
      end
    end
  end
end
