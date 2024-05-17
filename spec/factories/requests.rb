FactoryBot.define do
  factory :request do
    association :event
    association :attendee, factory: :user
    status { 'pending' }
    requestor { 'owner' }
  end
end
