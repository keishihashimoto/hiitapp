class HiitDate < ApplicationRecord
  belongs_to :hiit
  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to :wday
end
