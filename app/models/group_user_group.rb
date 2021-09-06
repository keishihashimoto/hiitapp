class GroupUserGroup
  include ActiveModel::Model
  attr_accessor :name, :hiit_id, :user_ids, :team_id

  # バリデーション
  with_options presence: true do
    validates :name
    validates :hiit_id
    validates :user_ids
    validates :team_id
  end

  # メソッド
  def save
    group = Group.create(name: name, hiit_id: hiit_id, team_id: team_id)
    user_ids.length.times do |i|
      UserGroup.create(group_id: group.id, user_id: user_ids[i])
    end
  end

  def update(id)
    # group_user_groupの情報を元に、groupインスタンス・user_groupインスタンスそれぞれの情報を既存のものと比較する。
    # 同一であれば何もしない。
    # 変更の必要があれば変更する。
    Group.find(id).update(name: name, hiit_id: hiit_id, team_id: team_id)
    
    user_ids.each do |user_id|
      if !(UserGroup.exists?(user_id: user_id, group_id: id)) && user_id != ""
        UserGroup.create(user_id: user_id, group_id: id)
      end
    end

    related_user_groups = []
    UserGroup.all.each do |user_group|
      if user_group.group.id == id
        related_user_groups << user_group
      end
    end

    related_user_groups.each do |related_user_group|
      binding.pry
      unless user_ids.include?(related_user_group.user_id.to_s)
        related_user_group.destroy
      end
    end
    
  end

end