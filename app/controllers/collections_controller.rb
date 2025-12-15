class CollectionsController < ApplicationController
  before_action :set_medium, only: [:create]
  before_action :set_collection, only: [:destroy]

  def index
    @collections = Collection.where(user_id: current_user.id).page(params[:page]).per(10)
  end

  def create
    @user = current_user
    @collection = Collection.new
    @collection.user_id = @user.id
    @collection.medium_id = @medium.id
    if @collection.save!
      redirect_to medium_collections_path(@medium), notice: "You've created a collection."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def next_up
    @user = current_user
    @media = @user.all_favorites(scope: [:next_up]).page(params[:page]).per(10)
  end

  def destroy
    if @collection.destroy!
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back(fallback_location: root_path) }
      end
    end
  end

  private

  def set_medium
    @medium = Medium.find(params[:medium_id])
  end

  def set_collection
    @collection = Collection.find(params[:id])
  end
end
