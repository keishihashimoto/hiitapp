class UserHiit < ApplicationRecord
  belongs_to :user
  belongs_to :hiit
  validates :done_dates, presence: true
end
