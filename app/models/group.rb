class Group < ApplicationRecord
  belongs_to :team
  belongs_to :hiit
  has_many :user_groups, dependent: :destroy
  has_many :users, through: :user_groups
end
