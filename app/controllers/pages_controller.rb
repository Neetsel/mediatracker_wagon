class PagesController < ApplicationController
  def home
  end

  def likes
    @media = []
    @media_liked = Favorite.like_list
    @media_liked.each { |liked_medium|
      medium = Medium.find(liked_medium["favoritable_id"])
      if current_user.favorited?(medium)
        @media << medium
      end
    }
  end
end
