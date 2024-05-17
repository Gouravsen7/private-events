FactoryBot.define do
  factory :event do
    name { Faker::Lorem.sentence }
    location { Faker::Address.full_address }
    start_time { Faker::Time.forward(days: 7, period: :morning) }
    end_time { Faker::Time.forward(days: 7, period: :evening) }
    date { Faker::Date.forward(days: 7) }
    event_type { 'private' }
    association :creator, factory: :user
  end
end
