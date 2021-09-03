class HiitDate < ApplicationRecord
  validates :date, null: false, numericality: { euqal_to_or_more_than: 0, euqal_to_or_less_than: 6 }
  belongs_to :hiit
  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to :wday
end
