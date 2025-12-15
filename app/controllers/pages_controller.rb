class PagesController < ApplicationController
  def home
  end

  def likes
    # @media = []
    # @media_liked = Favorite.like_list
    # @media_liked.each { |liked_medium|
    #   medium = Medium.find(liked_medium["favoritable_id"])
    #   if current_user.favorited?(medium)
    #     @media << medium
    #   end
    # }
    @user = current_user
    @media = @user.favorited_by_type("Medium", scope: "like").page(params[:page]).per(10)
  end
end
