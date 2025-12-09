class Book < ApplicationRecord
  has_one :media, as: :sub_media
end
