class UsersController < ApplicationController
  before_action :authenticate_user!

  def next_up
    @user = current_user
    @next_up_media = @user.favorited_by_type("Medium", scope: "next_up").page(params[:page]).per(10)
  end
end
