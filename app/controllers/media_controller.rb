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

  def toggle_settings

    @medium = Medium.find_by(title: params[:name], year: params[:year])

    unless @medium
      @medium = create_record_by_medium_type(params[:medium_type])
    end

    if params[:settings] === "collection"
      toggle_collection
    else
      toggle_favorites(params[:settings])
    end

    render json: @medium, status: :ok
  end

  def create_record
    create_record_by_medium_type(params[:medium_type])

    # @results = Kaminari.paginate_array(@results).page(current_page).per(10)

    respond_to do |format|
      format.html { redirect_to @medium, notice: "Medium added or already present" }
      format.turbo_stream { redirect_to @medium }
    end
  end

  def search
    current_page = params[:page] || 1
    case params[:medium_type]
    when "game"
      igdb = IgdbService.new
      @results = igdb.run(params[:title])
    when "movie"
      omdb = OmdbService.new
      @results = omdb.run(params[:title])
    when "book"
      open_library = OpenLibraryService.new
      @results = open_library.run(params[:title])
    end
    # A partir du result, on créé une page de 10 items
    @results = Kaminari.paginate_array(@results).page(current_page).per(10)

    respond_to do |format|
      format.html { render :index }
      format.turbo_stream
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

  def toggle_collection
    collection = Collection.find_by(medium_id: @medium.id, user_id: current_user.id)
    if collection.nil?
      respond_to do |format|
        format.html { redirect_to @medium }
        format.turbo_stream { redirect_to create_from_card_collection_path(@medium), data: { turbo_method:"POST" } }
      end
    else
      collection.destroy
      respond_to do |format|
        format.html { redirect_back(fallback_location: root_path) }
        format.turbo_stream
      end
    end
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
      @developer = params[:developers]
      @publisher = params[:publishers]
      @platforms = params[:platforms]
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

  def create_from_omdb
    omdb = OmdbService.new
    response = omdb.search_by_id(@imdbID)

    if response["Response"] == "True"
      # Si medium existe déjà, on le récupère(cf.doc active record)
      @medium = Medium.find_or_initialize_by(title: response["Title"], release_date: response["Released"])

      # On met à jour les infos si besoin
      @medium.assign_attributes(
        title: response["Title"],
        description: response["Plot"],
        release_date: response["Released"],
        year: response["Year"],
        genres: response["Genre"].split(", "),
        poster_url: response["Poster"]
      )

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
      # Si medium existe déjà, on le récupère(cf.doc active record)
      @medium = Medium.find_or_initialize_by(title: response["title"], year: @first_publish_year)
      # On met à jour les infos si besoin
      @medium.assign_attributes(
        title: response["title"],
        description: response["description"]["value"],
        release_date: Date.new(@first_publish_year.to_i,1,1),
        year: @first_publish_year,
        genres: genres,
        poster_url: "https://covers.openlibrary.org/b/olid/#{@cover_edition_key}-M.jpg"
      )

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
      # On convertit la date reçue en Unix
      release_date = DateTime.strptime(response[0]["first_release_date"].to_s, '%s')

      # Si medium existe déjà, on le récupère(cf.doc active record)
      @medium = Medium.find_or_initialize_by(title: response[0]["name"], release_date: release_date)

      @medium.assign_attributes(
        title: response[0]["name"],
        description: response[0]["summary"],
        release_date: release_date,
        year: release_date.year,
        genres: genres_names,
        poster_url: @cover
      )

      companies = []
      publishers = []
      developers = []

      if @publisher || @developer

        if @publisher && @developer
          companies = @publisher + @developer
        elsif @developer
          companies = @developer
        elsif
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
    # On save seulement si c'est un nouveau record
    @medium.save if @medium.new_record? || @medium.changed?
  end

  def set_medium
    if params[:id] == "search_from_omdb"
      @medium = OmdbService.new.search_by_id(params[:imdb_id])
    else
    @medium = Medium.find(params[:id])
    end
  end
end
