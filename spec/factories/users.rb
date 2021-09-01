FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.free_email }
    password = Faker::Internet.password
    password { password }
    password_confirmation { password }
    admin { true }
    association :team
  end
end
