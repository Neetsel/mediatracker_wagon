class CollectionsController < ApplicationController
  before_action :set_medium, only: [:create]

  def index
    @collections = Collection.where(user_id: current_user.id)
  end

  def create
    @user = current_user
    @collection = Collection.new
    @collection.user_id = @user.id
    @collection.medium_id = @medium.id
    if @collection.save!
      @user.favorite(@collection)
      redirect_to medium_collections_path(@medium), notice: "You've created a collection."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_medium
    @medium = Medium.find(params[:medium_id])
  end
end
