class PagesController < ApplicationController
  def home
  end

  def likes
    @media = []
    @media_liked = Favorite.like_list
    @media_liked.each { |liked_medium| @media << Medium.find(liked_medium["favoritable_id"]) }
  end
end
