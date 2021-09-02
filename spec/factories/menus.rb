FactoryBot.define do
  factory :menu do
    name { Faker::Name.name }
    text { Faker::Lorem.sentence }

    association :team

    after(:build, :create) do |menu|
      menu.icon.attach(io: File.open(Rails.root.join("app/assets/images/no_image.jpeg")), filename: "no_image.jpeg")
    end
  end
end
