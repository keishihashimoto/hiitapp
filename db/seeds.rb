# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# group, group_user, user_hiit

20.times do |i|
  Group.create(team_id: 10, hiit_id: Hiit.all[i].id, name: Faker::Name.name)
  UserGroup.create(user_id: 33, group_id: Group.all[i].id)
  UserGroup.create(user_id: 34, group_id: Group.all[i].id)
end