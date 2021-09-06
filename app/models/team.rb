class Team < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: true
  has_many :users, dependent: :destroy  
  has_many :menus, dependent: :destroy
  has_many :hiits, dependent: :destroy
  has_many :groups, dependent: :destroy

end
