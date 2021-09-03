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
  validate :collect_date?
  validate :eight_menus?

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

  # menu_idsが8つのmenu_idを持っているかどうかを判定するバリデーションメソッド
  def eight_menus?
    if menu_ids != [] || menu_ids.length != 8 || menu_ids.include?("")
      errors.add(:menu_ids, "must be choosen at eight-times")
    end
  end

  # dateが0~6以外の数字を持っていないかどうか、また要素の数が８つ以上になっていないかどうかを判定するバリデーションメソッド
  def collect_date?

    if date = []
      if date.length >= 8
        errors.add(:date, "is invalid")
      else
        date.each do |d|
          if d >= 7 || d < 0
            errors.add(:date, "is invalid")
            return
          end
        end
      end
    end

  end

end