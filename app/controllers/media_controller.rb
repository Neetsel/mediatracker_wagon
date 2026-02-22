class MediaController < ApplicationController
  before_action :set_medium, only: [:show, :toggle_settings, :check_settings]

  def index
    @media = Medium.all
  end

  def show
    update_data_by_medium_type
  end

  def check_settings
    favorite = current_user.favorited?(@medium, scope: params[:settings])
    response = { medium: @medium, favorite: favorite}

    render json: response, status: :ok
  end

  def toggle_settings

    unless params[:settings] === "collection"
      toggle_favorites(params[:settings])
    end

    render json: @medium, status: :ok
  end

  def search
    case params[:medium_type]
    when "game"
      current_page = params[:page] || 1
      igdb = IgdbService.new
      @fetched_data = igdb.run(params[:title])

      @results_all = initial_game_creation
      @results = Kaminari.paginate_array(@results_all).page(current_page).per(10)

    when "movie"
      current_page = params[:page] || 1
      omdb = OmdbService.new
      @fetched_data = omdb.run(params[:title])

      @results_all = initial_movie_creation
      @results = Kaminari.paginate_array(@results_all).page(current_page).per(10)

    when "book"
      current_page = params[:page] || 1
      open_library = OpenLibraryService.new
      @fetched_data = open_library.run(params[:title])

      @results_all = initial_book_creation
      @results = Kaminari.paginate_array(@results_all).page(current_page).per(10)
    end
  end

  private

  def update_data_by_medium_type
    if @medium.sub_media_type === "Game"
      add_game_details

    elsif @medium.sub_media_type === "Book"
      add_book_details

    elsif @medium.sub_media_type === "Movie"
      add_movie_details
    end
  end

  def toggle_favorites(scope)
    if(current_user.favorited?(@medium, scope: scope))
      current_user.unfavorite(@medium, scope: scope)
    else
      current_user.favorite(@medium, scope: scope)
    end
    current_user.save!
  end

  def initial_movie_creation
    movies = []

    @fetched_data.each {|movie|

      @medium = Medium.initial_movie_creation(movie)
      @medium.sub_media = Movie.initial_creation(movie)
      save_medium
      movies << @medium
    }

    movies
  end

  def initial_book_creation
    books = []

    @fetched_data.each {|book|

      @medium = Medium.initial_book_creation(book)
      @medium.sub_media = Book.initial_creation(book)
      save_medium
      books << @medium
    }

    books
  end

  def initial_game_creation
    games = []

    @fetched_data.each {|game|

      @medium = Medium.initial_game_creation(game)
      @medium.sub_media = Game.initial_creation(game)
      save_medium
      games << @medium
    }

    games
  end

  def add_movie_details
    omdb = OmdbService.new
    response = omdb.search_by_id(@medium.sub_media.api_id)

    if response["Response"] == "True"

      @medium = Medium.update_from_omdb(response)

      # À partir de la response, on génère un film
      # Ensuite, on assigne ce film à sub_media
      @medium.sub_media = Movie.update(response)

      # On sauve le medium maintenant qu'il est bien remplit
      save_medium
      @medium
    else
      redirect_to media_path, alert: "Medium not available."
    end
  end

  def add_book_details

    open_library = OpenLibraryService.new
    response = open_library.search_work_by_key(@medium.sub_media.work_id)
    response_book = open_library.search_book_by_key(@medium.sub_media.book_id)

    if response
      @medium = Medium.update_from_open_library(response, response_book, @medium.year)
      # À partir de la response, on génère un livre
      # Ensuite, on assigne ce livre à sub_media
      @medium.sub_media = Book.update(response, response_book)
      # On sauve le medium maintenant qu'il est bien remplit
      save_medium
      @medium
    else
      redirect_to media_path, alert: "Medium not available."
    end
  end

  def add_game_details
    igdb = IgdbService.new
    # On fait un call API pour récupérer la fiche spécifique au jeu qui nous donnera sa description
    response = JSON.parse(igdb.search_by_id(@medium.sub_media.api_id).body)

    if response
      genres_names = igdb.fetch_genres(response[0])

      @medium = Medium.update_from_igdb(response[0], genres_names, @medium.year)

      companies = igdb.fetch_companies(@medium.sub_media.publishers_ref, @medium.sub_media.developers_ref)
      publishers = igdb.fetch_publishers(@medium.sub_media.publishers_ref, companies)
      developers = igdb.fetch_developers(@medium.sub_media.developers_ref, companies)

      # On prépare un array dans lequel on va mettre le nom de toutes les plateformes
      platforms = igdb.fetch_platforms(@medium.sub_media.platforms_ref)

      @medium.sub_media = Game.update(response[0], developers, publishers, platforms)

      save_medium
      @medium
    else
      redirect_to media_path, alert: "Medium not available."
    end
  end

  def save_medium
    @medium.save! if @medium.new_record? || @medium.changed?
  end


  def set_medium
    @medium = Medium.find(params[:id])
  end
end
