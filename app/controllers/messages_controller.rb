class MessagesController < ApplicationController
  SYSTEM_PROMPT_MOVIES = "You are a media expert.\n\nI am a movie fan, looking for new movies to watch.\n\nHelp me find new movies with similar genres, themes or people involved in the making of those movies. Don't recommend movies that I've seen or plan to see.\n\nAnswer concisely in Markdown."
  SYSTEM_PROMPT_GAMES = "You are a media expert.\n\nI am a video game fan, looking for new video games to play.\n\nHelp me find new games with similar genres, themes or people involved in the making of those games. Don't recommend games that I've played or plan to play.\n\nAnswer concisely in Markdown."
  SYSTEM_PROMPT_BOOKS = "You are a media expert.\n\nI am a book fan, looking for new books to read.\n\nHelp me find new books with similar genres, themes or people involved in the making of those books. Don't recommend books that I've read or plan to read.\n\nAnswer concisely in Markdown."

  def create
    @chat = Chat.find(params[:chat_id])
    @medium = @chat.medium
    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save
      @ruby_llm_chat = RubyLLM.chat
      build_conversation_history
      response = @ruby_llm_chat.with_instructions(instructions).ask(@message.content)
      @chat.messages.create(role: "assistant", content: response.content)
      destroy_old_messages

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to chat_path(@chat) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_message_container", partial: "messages/form", locals: { chat: @chat, message: @message }) }
        format.html { render "chats/show", status: :unprocessable_entity }
      end
    end
  end

  private

  def build_conversation_history
    @chat.messages.each do |message|
      @ruby_llm_chat.add_message(role: message.role, content: message.content)
    end
  end

  def destroy_old_messages
    chat_length = @chat.messages.length
    amount_to_keep = 10
    if chat_length > amount_to_keep
      amount_to_destroy = chat_length - amount_to_keep
      @chat.messages[0, amount_to_destroy].each do |message|
        message.destroy
      end
    end
  end

  def medium_title
    "Here is the title of the #{@medium.sub_media_type.downcase}: #{@medium.title}."
  end

  def medium_description
    "Here is the description of the #{@medium.sub_media_type.downcase}: #{@medium.description}."
  end

  def medium_year
    "Here is the release year of the #{@medium.sub_media_type.downcase}: #{@medium.year}."
  end

  def list_media_liked
    media_type = ""
    liked_media_text=""
    if @medium.sub_media_type === "Movie"
      liked_media_text = "Here is the list of movies I liked and seen: \n"
      media_type = "Movie"
    elsif @medium.sub_media_type === "Game"
      liked_media_text = "Here is the list of games I liked and played: \n"
      media_type = "Game"
    else
      liked_media_text = "Here is the list of books I liked and read: \n"
      media_type = "Book"
    end

    # for medium in Favorite.liked_list
    #   if (medium.sub_media_type === media_type)
    #     liked_medium_text << "#{medium.medium.title} (#{medium.medium.year}) \n"
    #   end
    # end

    # liked_media_text
  end

  def list_media_seen
    media_type = ""
    seen_media_text = ""
    if @medium.sub_media_type === "Movie"
      seen_media_text = "Here is the list of movies I've seen: \n"
      media_type = "Movie"
    elsif @medium.sub_media_type === "Game"
      seen_media_text = "Here is the list of games I've played: \n"
      media_type = "Game"
    else
      seen_media_text = "Here is the list of books I've read: \n"
      media_type = "Book"
    end

    # seen_media_text
  end

  def list_media_planned
    media_type = ""
    planned_media_text = ""
    if @medium.sub_media_type === "Movie"
      planned_media_text = "Here is the list of movies I already plan to see: \n"
      media_type = "Movie"
    elsif @medium.sub_media_type === "Game"
      planned_media_text = "Here is the list of games I already plan to play: \n"
      media_type = "Game"
    else
      planned_media_text = "Here is the list of books I already plan to read: \n"
      media_type = "Book"
    end

    # for medium in Favorite.next_up_list
    #   if (medium.sub_media_type === media_type)
    #     liked_medium_text << "#{medium.medium.title} (#{medium.medium.year}) \n"
    #   end
    # end

    # planned_media_text
  end

  def system_prompt_selection
    if @medium.sub_media_type === "Movie"
      SYSTEM_PROMPT_MOVIES
    elsif @medium.sub_media_type === "Game"
      SYSTEM_PROMPT_GAMES
    else
      SYSTEM_PROMPT_BOOKS
    end
  end

  def instructions
    [system_prompt_selection, medium_title, medium_year, medium_description].compact.join("\n\n")
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
