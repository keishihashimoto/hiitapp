class Menu < ApplicationRecord
  validates :name, precense: true
  belongs_to :team
  has_one_attached :icon
end
