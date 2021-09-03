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

end