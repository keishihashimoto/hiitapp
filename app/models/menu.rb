class Menu < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: true }, if: :existing_menu
  belongs_to :team
  has_one_attached :icon
  has_many :menu_hiits, dependent: :destroy
  has_many :hiits, through: :menu_hiits

  def existing_menu
    if Menu.exists?(name: name, team_id: team_id)
      return true
    else
      return false
    end
  end
end