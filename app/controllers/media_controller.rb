class MediaController < ApplicationController
  before_action :set_medium, only: [:show, :toggle_likes, :toggle_next_up]

  def index
    @media = Medium.all
  end

  def show
  end

  def toggle_likes
    toggle_favorites("like")
  end

  def toggle_next_up
    toggle_favorites("next_up")
  end

  def check_settings
    @medium = Medium.find_by(title: params[:name], year: params[:year])

    if @medium
      favorite = current_user.favorited?(@medium, scope: params[:settings])
      response = { medium: @medium, favorite: favorite}
    else
      response = { favorite: false}
    end

    render json: response, status: :ok
  end

  def toggle_settings

    @medium = Medium.find_by(title: params[:name], year: params[:year])

    unless @medium
      @medium = create_record_by_medium_type(params[:medium_type])
    end

    unless params[:settings] === "collection"
      toggle_favorites(params[:settings])
    end

    render json: @medium, status: :ok
  end

  def create_record
    create_record_by_medium_type(params[:medium_type])

    respond_to do |format|
      format.html { redirect_to medium_path(@medium), notice: "Medium added or already present" }
      format.turbo_stream { redirect_to medium_path(@medium) }
    end
  end

  def search
    case params[:medium_type]
    when "game"
      current_page = params[:page] || 1
      igdb = IgdbService.new
      @results = igdb.run(params[:title])

      initial_game_creation
      @results = Kaminari.paginate_array(@results).page(current_page).per(10)
    when "movie"
      current_page = params[:page] || 1
      omdb = OmdbService.new
      @results = omdb.run(params[:title])

      initial_movie_creation
      @results = Kaminari.paginate_array(@results).page(current_page).per(10)
    when "book"
      current_page = params[:page] || 1
      open_library = OpenLibraryService.new
      @results = open_library.run(params[:title])

      initial_book_creation
      @results = Kaminari.paginate_array(@results).page(current_page).per(10)
    end
  end

  private

  def create_record_by_medium_type(medium_type)
    if medium_type === "game"
      setup_data_for_igdb
      create_from_igdb
    elsif medium_type === "book"
      setup_data_for_open_library
      create_from_open_library
    elsif medium_type === "movie"
      setup_data_for_omdb
      create_from_omdb
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

  def setup_data_for_omdb
    if params[:medium].nil?
      @imdbID = params[:id]
    else
      @imdbID = params[:medium]["imdbID"]
    end
  end

  def setup_data_for_open_library
    if params[:medium].nil?
      @key = "/works/#{params[:id]}"
      @cover_edition_key = params[:cover]
      @first_publish_year = params[:year]
      @author_name = params[:author]
    else
      @key = "#{params[:medium][:key]}"
      @cover_edition_key = params[:medium][:cover_edition_key]
      @first_publish_year = params[:medium][:first_publish_year]
      @author_name = params[:medium][:author_name]
    end
  end

  def setup_data_for_igdb
    if params[:medium].nil?
      @id = params[:id]
      @cover = params[:cover]
      @developer = params[:developers].split(", ")
      @publisher = params[:publishers].split(", ")
      @platforms = params[:platforms].split(", ")
      @story_duration = params[:story_duration]
      @extras_duration = params[:extras_duration]
      @completionist_duration = params[:completionist_duration]
    else
      @id = params[:medium][:id]
      @cover = params[:medium][:cover]
      @developer = params[:medium][:developer]
      @publisher = params[:medium][:publisher]
      @platforms = params[:medium][:platforms]
      @story_duration = params[:medium][:main_story_duration]
      @extras_duration = params[:medium][:main_extras_duration]
      @completionist_duration = params[:medium][:completionist_duration]
    end
  end

  def initial_movie_creation

    @results.each {|movie|
      @medium = Medium.initial_movie_creation(movie)
      @medium.sub_media = Movie.initial_creation(movie)
      save_medium
    }
  end

  def initial_book_creation

    @results.each {|book|
      @medium = Medium.initial_book_creation(book)
      @medium.sub_media = Book.initial_creation(book)
      save_medium
    }
  end

  def initial_game_creation

    @results.each {|game|
      @medium = Medium.initial_game_creation(game)
      @medium.sub_media = Game.initial_creation(game)
      save_medium
    }
  end

  def add_movie_details


  end

  def add_book_details


  end

  def add_game_details


  end

  def create_from_omdb
    omdb = OmdbService.new
    response = omdb.search_by_id(@imdbID)

    if response["Response"] == "True"

      @medium = Medium.create_from_omdb(response)

      # À partir de la response, on génère un film
      # Ensuite, on assigne ce film à sub_media
      @medium.sub_media = Movie.create_from_medium(response)

      # On sauve le medium maintenant qu'il est bien remplit
      save_medium
      @medium
    else
      redirect_to media_path, alert: "Medium not available."
    end
  end

  def create_from_open_library
    open_library = OpenLibraryService.new
    response = open_library.search_work_by_key(@key)
    response_book = open_library.search_book_by_key(@cover_edition_key)

    response_book["subjects"] ? genres = response_book["subjects"].split(", ") : genres = []

    if response

      @medium = Medium.create_from_open_library(response, @first_publish_year, @cover_edition_key, genres)
      # À partir de la response, on génère un livre
      # Ensuite, on assigne ce livre à sub_media
      @medium.sub_media = Book.create_from_medium(@cover_edition_key, @key, response_book["number_of_pages"], @author_name)

      # On sauve le medium maintenant qu'il est bien remplit
      save_medium
      @medium
    else
      redirect_to media_path, alert: "Medium not available."
    end
  end

  def create_from_igdb
    igdb = IgdbService.new
    # On fait un call API pour récupérer la fiche spécifique au jeu qui nous donnera sa description
    response = JSON.parse(igdb.search_by_id(@id).body)

    genres_names = []
    if response[0]["genres"]
      # On fait un call API pour récupérer le nom des genres
      response_genres = JSON.parse(igdb.genres_by_id(response[0]["genres"]).body)
      # On prépare un array dans lequel on va mettre le nom de tous les genres
      response_genres.each {|genre|
        genres_names << genre["name"]
      }
    end

    if response

      @medium = Medium.create_from_igdb(response, genres_names, @cover)

      companies = []
      publishers = []
      developers = []

      if @publisher || @developer

        if @publisher && @developer
          companies = @publisher + @developer
        elsif @developer
          companies = @developer
        else
          companies = @publisher
        end

        # On fait un call API pour récupérer le nom de toutes les entreprises impliquées dans la création
        response_companies_name = JSON.parse(igdb.companies_name_by_id(companies).body)
        # On prépare un array dans lequel on va mettre le nom de tous les éditeurs du jeu

        if @publisher
          @publisher.each {|publisher|
            # On cherche le publisher sur base de son id
            publisher_name = response_companies_name.select { |hash| hash["id"] == publisher.to_i }
            # On ajoute son nom à l'array
            publishers << publisher_name[0]["name"]
          }
          publishers = publishers.join(", ")
        end
        # On prépare un array dans lequel on va mettre le nom de tous les développeurs du jeu

        if @developer
          @developer.each {|developer|
            # On cherche le développeur sur base de son id
            developer_name = response_companies_name.select { |hash| hash["id"] == developer.to_i }
            # On ajoute son nom à l'array
            developers << developer_name[0]["name"]
          }
        end
      end
      # On prépare un array dans lequel on va mettre le nom de toutes les plateformes
      platforms = []

      if @platforms
        # On fait un call API pour récupérer le nom de toutes les plateformes
        response_platforms = JSON.parse(igdb.platforms_by_id(@platforms).body)

        response_platforms.each {|platform|
          platforms << platform["name"]
        }
      end

      @medium.sub_media = Game.create_from_medium(@id, developers, publishers, platforms, @story_duration, @extras_duration, @completionist_duration)

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
    if params[:id] == "search_from_omdb"
      @medium = OmdbService.new.search_by_id(params[:imdb_id])
    else
      @medium = Medium.find(params[:id])
    end
  end
end
