class Review < ApplicationRecord
  belongs_to :medium
  belongs_to :user
end
