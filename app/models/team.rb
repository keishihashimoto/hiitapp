class Team < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: true
  has_many :users  
  has_many :menus
  has_many :hiits
  has_many :groups

end
