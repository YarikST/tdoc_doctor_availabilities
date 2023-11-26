FactoryBot.define do
  factory :working_hour do
    association :doctor

    start_at { Time.zone.parse("09:00") }
    end_at { Time.zone.parse("18:00") }
    wday { 1 }
  end
end
