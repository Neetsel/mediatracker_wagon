class Medium < ApplicationRecord

  belongs_to :sub_media, polymorphic: true
  has_many :reviews
  has_many :collections
  has_many :chats
end
