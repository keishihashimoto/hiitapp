class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :name, presence: true
  belongs_to :team
  has_many :user_hiits, dependent: :destroy
  has_many :hiits, through: :user_hiits
  has_many :user_groups, dependent: :destroy
  has_many :groups, through: :user_groups
end
