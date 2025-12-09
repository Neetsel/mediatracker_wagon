class Chat < ApplicationRecord
  belongs_to :user
  belongs_to :medium
  has_many :messages, dependent: :destroy
end
