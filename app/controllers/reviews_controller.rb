class ReviewsController < ApplicationController
  before_action :set_medium, only: [:new, :create]
  before_action :set_review, only: [:show]

  def index
    @reviews = Review.where(user_id: current_user.id).page(params[:page]).per(10)
  end

  def show
  end

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

  def set_review
    @review = Review.find(params[:id])
  end
end
