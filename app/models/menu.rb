class Menu < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: true
  belongs_to :team
  has_one_attached :icon
end
