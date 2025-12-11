class Collection < ApplicationRecord
  acts_as_favoritable
  belongs_to :user
  belongs_to :medium
  has_many :media_consumption
end
