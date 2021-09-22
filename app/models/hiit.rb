class Hiit < ApplicationRecord
  belongs_to :team
  has_many :user_hiits, dependent: :destroy
  has_many :users, through: :user_hiits
  has_many :menu_hiits, dependent: :destroy
  has_many :menus, through: :menu_hiits
  has_many :hiit_dates, dependent: :destroy
  has_one :group
  # with_options presence: true do
   # validates :name
   # validates :date
   # validates :active_time, format: { with: /\A[0-9]{2}[分秒]\z/ }
   # validates :rest_time, format: { with: /\A[0-9]{2}[分秒]\z/ }
  # end
end 