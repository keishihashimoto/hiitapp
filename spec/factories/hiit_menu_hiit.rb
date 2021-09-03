FactoryBot.define do
  factory :hiit_menu_hiit do
    name { Faker::Name.name }
    active_time = Faker::Number.number(digits: 2)
    active_time { "#{active_time}秒" }
    rest_time = Faker::Number.number(digits: 2)
    rest_time { "#{rest_time}秒" }
    date = [0, 1, 2, 3, 4, 5, 6]
    date { date }
  end
end