FactoryBot.define do
  factory :appointment do
    association :doctor
    association :patient

    start_at { Time.zone.parse("09:00") }
    end_at { Time.zone.parse("18:00") }
    wday { 1 }
    disease { 'headache' }
  end
end
