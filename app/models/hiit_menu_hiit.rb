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

  def update(id)
    # hiitインスタンスに関しては、idが同一のものに対してupdateを行って欲しい。
    hiit = Hiit.find(id)
    hiit.update(name: name, active_time: active_time, rest_time: rest_time, team_id: team_id)
    # menu_hiitインスタンスに関しては、既存のmenu_hiitsのi番目と新しいmenu_hiitsのi番目を比べる。
    # 両者が同一であれば何もしない。
    # 両者が一致していなければ、古い方を削除して新しいレコードを保存する。
    old_menu_hiits = Hiit.find(id).menu_hiits
    
    old_menu_hiit_0 = old_menu_hiits[0]
    old_menu_hiit_1 = old_menu_hiits[1]
    old_menu_hiit_2 = old_menu_hiits[2]
    old_menu_hiit_3 = old_menu_hiits[3]
    old_menu_hiit_4 = old_menu_hiits[4]
    old_menu_hiit_5 = old_menu_hiits[5]
    old_menu_hiit_6 = old_menu_hiits[6]
    old_menu_hiit_7 = old_menu_hiits[7]

    new_menu_hiit_0 = MenuHiit.new(hiit_id: hiit.id, menu_id: menu_ids[0])
    new_menu_hiit_1 = MenuHiit.new(hiit_id: hiit.id, menu_id: menu_ids[1])
    new_menu_hiit_2 = MenuHiit.new(hiit_id: hiit.id, menu_id: menu_ids[2])
    new_menu_hiit_3 = MenuHiit.new(hiit_id: hiit.id, menu_id: menu_ids[3])
    new_menu_hiit_4 = MenuHiit.new(hiit_id: hiit.id, menu_id: menu_ids[4])
    new_menu_hiit_5 = MenuHiit.new(hiit_id: hiit.id, menu_id: menu_ids[5])
    new_menu_hiit_6 = MenuHiit.new(hiit_id: hiit.id, menu_id: menu_ids[6])
    new_menu_hiit_7 = MenuHiit.new(hiit_id: hiit.id, menu_id: menu_ids[7])

    unless old_menu_hiit_0 == new_menu_hiit_0
      old_menu_hiit_0.destroy unless old_menu_hiit_0 == nil
      new_menu_hiit_0.save
    end

    unless old_menu_hiit_1 == new_menu_hiit_1
      old_menu_hiit_1.destroy unless old_menu_hiit_1 == nil
      new_menu_hiit_1.save
    end
      
    unless old_menu_hiit_2 == new_menu_hiit_2
      old_menu_hiit_2.destroy unless old_menu_hiit_2 == nil
      new_menu_hiit_2.save
    end

    unless old_menu_hiit_3 == new_menu_hiit_3
      old_menu_hiit_3.destroy unless old_menu_hiit_3 == nil
      new_menu_hiit_3.save
    end

    unless old_menu_hiit_4 == new_menu_hiit_4
      old_menu_hiit_4.destroy unless old_menu_hiit_4 == nil
      new_menu_hiit_4.save
    end

    unless old_menu_hiit_5 == new_menu_hiit_5
      old_menu_hiit_5.destroy unless old_menu_hiit_5 == nil
      new_menu_hiit_5.save
    end

    unless old_menu_hiit_6 == new_menu_hiit_6
      old_menu_hiit_6.destroy unless old_menu_hiit_6 == nil
      new_menu_hiit_6.save
    end

    unless old_menu_hiit_7 == new_menu_hiit_7
      old_menu_hiit_7.destroy unless old_menu_hiit_7 == nil
      new_menu_hiit_7.save
    end

    7.times do |i|
      if HiitDate.exists?(hiit_id: hiit.id, date: i) && !(date.include?(i.to_s))
        HiitDate.where(hiit_id: hiit.id, date: i).each do |hiit_date|
          hiit_date.destroy
        end
      elsif !(HiitDate.exists?(hiit_id: hiit.id, date: i)) && date.include?(i.to_s)
        HiitDate.create(hiit_id: hiit.id, date: i)
      end
    end
  end

  def set_old_menu_hiits
    Hiit.find(id).menu_hiits
  end

  # menu_idsが8つのmenu_idを持っているかどうかを判定するバリデーションメソッド
  def eight_menus?
    if menu_ids == [] || menu_ids.length != 8 || menu_ids.include?("") || menu_ids.include?("0")
      errors.add(:menu_ids, "must be choosen at eight-times")
    end
  end

  # dateが0~6以外の数字を持っていないかどうか、また要素の数が８つ以上になっていないかどうかを判定するバリデーションメソッド
  def collect_date?

    if date != nil
      if date.length >= 8
        errors.add(:date, "is invalid")
      else
        date.each do |d|
          if d.to_i >= 7 || d.to_i < 0
            errors.add(:date, "is invalid")
            return
          end
        end
      end
    end

  end

end