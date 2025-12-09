class ReviewsController < ApplicationController
  before_action :set_medium, only: [:new, :create]
  def new
    @review = Review.new
  end

  def create
    @user = current_user
    @review = Review.new(review_params)
    @review.user_id = @user.id
    @review.medium_id = @medium.id
    if @review.save!
      redirect_to reviews_medium_path(@medium), notice: "The review was created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_medium
    @medium = Medium.find(params[:medium_id])
  end

  def review_params
    params.require(:review).permit(:content, :rating)
  end
end
