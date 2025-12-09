class Medium < ApplicationRecord
  acts_as_favoritable
  belongs_to :sub_media, polymorphic: true
  has_many :reviews, :collections, :chats
end
