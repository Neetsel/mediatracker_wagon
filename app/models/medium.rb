class Medium < ApplicationRecord
  acts_as_favoritable
  belongs_to :sub_media, polymorphic: true
  has_many :reviews
  has_many :collections
  has_many :chats
end
