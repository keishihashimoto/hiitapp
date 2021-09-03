class HiitMenuHiit
  include ActiveModel::Model
  attr_accessor :name, :active_time, :rest_time, :date, :team_id, :menu_ids

  with_options presence: true do
    validates :name
    validates :date
    validates :menu_ids
    validates :team_id
    validates :active_time, format: { with: /\A[0-9]{1,2}[分秒]\z/ }
    validates :rest_time, format: { with: /\A[0-9]{1,2}[分秒]\z/ }
  end

  def save
    hiit = Hiit.create(name: name, active_time: active_time, rest_time: rest_time, team_id: team_id)
    MenuHiit.create(hiit_id: hiit.id, menu_id: menu_ids[0])
    MenuHiit.create(hiit_id: hiit.id, menu_id: menu_ids[1])
    MenuHiit.create(hiit_id: hiit.id, menu_id: menu_ids[2])
    MenuHiit.create(hiit_id: hiit.id, menu_id: menu_ids[3])
    MenuHiit.create(hiit_id: hiit.id, menu_id: menu_ids[4])
    MenuHiit.create(hiit_id: hiit.id, menu_id: menu_ids[5])
    MenuHiit.create(hiit_id: hiit.id, menu_id: menu_ids[6])
    MenuHiit.create(hiit_id: hiit.id, menu_id: menu_ids[7])
    date_count = date.length
    date_count.times do |i|
    HiitDate.create(hiit_id: hiit.id, date: date[i])
    end
  end

end