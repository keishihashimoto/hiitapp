class Menu < ApplicationRecord
  validates :name, precense: true
  belongs_to :team
end
