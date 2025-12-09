class Collection < ApplicationRecord
  belongs_to :user
  belongs_to :medium
  has_many :media_consumption
end
