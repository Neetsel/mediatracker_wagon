class ChatsController < ApplicationController
  before_action :set_chat, only: [:show]

  def index
    @chats = Chat.all
  end

  def create
    @user = current_user
    @medium = Medium.find(params[:medium_id])
    @title = "#{@medium.title} - chat"
    @chat = Chat.new(user_id: @user.id, medium_id: @medium.id, title: @title)

    if @chat.save!
      redirect_to chat_path(@chat)
    end
  end

  def show
  end

  private

  def set_chat
    @chat = Chat.find(params[:id])
    @message = Message.new
  end
end
