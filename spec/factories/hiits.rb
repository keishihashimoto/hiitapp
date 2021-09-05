FactoryBot.define do
  factory :hiit do
    name { Faker::Name.name }
    active_time = Faker::Number.number(digits: 2)
    active_time { "#{active_time}秒" }
    rest_time = Faker::Number.number(digits: 2)
    rest_time { "#{rest_time}秒" }

  end
end
