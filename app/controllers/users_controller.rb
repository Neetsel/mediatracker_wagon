class UsersController < ApplicationController
  before_action :authenticate_user!

  def next_up
    @user = current_user
    @next_up_media = @user.favorited_by_type("Medium", scope: "next_up").page(params[:page]).per(10)
  end

  def stats
    @user = current_user
    @collection_media = Medium.joins(:collections).merge(Collection.where(user_id: @user.id)).page(params[:page]).per(10)
    @next_up_media = @user.favorited_by_type("Medium", scope: "next_up").page(params[:page]).per(10)
    @like_media = @user.favorited_by_type("Medium", scope: "like").page(params[:page]).per(10)
  end
end
