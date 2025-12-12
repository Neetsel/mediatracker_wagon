class MediaController < ApplicationController
  before_action :set_medium, only: [:show, :toggle_next_up, :toggle_likes]

  def index
    @media = Medium.all
  end

  def show
  end

  def toggle_likes
    if(current_user.favorited?(@medium, scope: :likes))
      current_user.unfavorite(@medium, scope: :likes)
    else
      current_user.favorite(@medium, scope: :likes)
    end
    current_user.save!

    respond_to do |format|
      format.html { redirect_to @medium, notice: "Medium added or already present" }
      format.turbo_stream { redirect_to @medium }
    end
  end

  def toggle_next_up
    if current_user.favorited?(@medium, scope: :next_up)
      current_user.unfavorite(@medium, scope: :next_up)
    else
      current_user.favorite(@medium, scope: :next_up)
    end
    current_user.save!

    respond_to do |format|
      format.html { redirect_to @medium, notice: "Media added or already present"}
      format.turbo_stream { redirect_to @medium }
    end
  end

  def create_from_igdb
    igdb = IgdbService.new
    # On fait un call API pour récupérer la fiche spécifique au jeu qui nous donnera sa description
    response = JSON.parse(igdb.search_by_id(params[:id]).body)

    # On fait un call API pour récupérer le nom des genres
    response_genres = JSON.parse(igdb.genres_by_id(response[0]["genres"]).body)
    # On prépare un array dans lequel on va mettre le nom de tous les genres
    genres_names = []
    response_genres.each {|genre|
      genres_names << genre["name"]
    }

    if response
      # Si medium existe déjà, on le récupère(cf.doc active record)
      @medium = Medium.find_or_initialize_by(title: response[0]["name"])

      # On convertit la date reçue en Unix
      release_date = DateTime.strptime(response[0]["first_release_date"].to_s, '%s')
      @medium.assign_attributes(
        title: response[0]["name"],
        description: response[0]["summary"],
        release_date: release_date,
        year: release_date.year,
        genres: genres_names,
        poster_url: params[:cover]
      )

      companies = []

      if params[:publisher] && params[:developer]
        companies = params[:publisher] + params[:developer]
      elsif params[:developer]
        companies = params[:developer]
      elsif
        companies = params[:publisher]
      end

      # On fait un call API pour récupérer le nom de toutes les entreprises impliquées dans la création
      response_companies_name = JSON.parse(igdb.companies_name_by_id(companies).body)
      # On prépare un array dans lequel on va mettre le nom de tous les éditeurs du jeu
      publishers = []
      if params[:publisher]
        params[:publisher].each {|publisher|
          # On cherche le publisher sur base de son id
          publisher_name = response_companies_name.select { |hash| hash["id"] == publisher.to_i }
          # On ajoute son nom à l'array
          publishers << publisher_name[0]["name"]
        }
      end
      # On prépare un array dans lequel on va mettre le nom de tous les développeurs du jeu
      developers = []
      if params[:developer]
        params[:developer].each {|developer|
          # On cherche le développeur sur base de son id
          developer_name = response_companies_name.select { |hash| hash["id"] == developer.to_i }
          # On ajoute son nom à l'array
          developers << developer_name[0]["name"]
        }
      end

      # On fait un call API pour récupérer le nom de toutes les plateformes
      response_platforms = JSON.parse(igdb.platforms_by_id(params[:platforms]).body)
      # On prépare un array dans lequel on va mettre le nom de toutes les plateformes
      platforms = []
      response_platforms.each {|platform|
        platforms << platform["name"]
      }

      @medium.sub_media = Game.create_from_medium(params[:id], developers, publishers, platforms, params[:main_story_duration], params[:main_extras_duration], params[:completionist_duration])

      save_medium
    else
      redirect_to media_path, alert: "Medium not available."
    end
  end

  def search_from_igdb
    igdb = IgdbService.new
    # On fait un call API pour récupérer tous les jeux qui portent un nom similaire
    response = JSON.parse(igdb.search_by_title(params[:title]).body)

    # On prépare un array qui contient les références de toutes les covers que l on veut récupérer
    covers_id = []
    response.each {|game|
      if game["cover"]
        covers_id << game["cover"]
      end
    }

    # On prépare un array qui contient les références de tous les game_id qui nous serviront à trouver les durées de jeux et les compagnies qui ont bossé dessus
    games_id = []
    response.each {|game|
      if game["id"]
        games_id << game["id"]
      end
    }

    # On fait les calls API nécessaires pour récupérer les covers, les durées de jeux et les compagnies
    response_cover = JSON.parse(igdb.cover_by_id(covers_id).body)
    response_duration = JSON.parse(igdb.duration_by_id(games_id).body)
    response_companies = JSON.parse(igdb.involved_companies_by_id(games_id).body)

    # On modifie la réponse afin de lui ajouter les infos des 3 derniers calls API
    response.map {|game|

      # On ajoute la cover si le jeu en a une
      if game["cover"]
        # On fait le lien entre la ref de game["cover"] et notre réponse de l'API cover
        cover = response_cover.select { |hash| hash["id"] === game["cover"] }
        # l'url custom permet d'avoir l image en meilleure résolution
        game["cover"] = "//images.igdb.com/igdb/image/upload/t_720p/#{cover[0]["image_id"]}.png"
      end

      # On ajoute la date de sortie si il y en a une
      if game["first_release_date"]
        # On convertit la date reçue en Unix pour avoir l'année
        game["first_release_date"] = DateTime.strptime(game["first_release_date"].to_s, '%s').year
      end

      # On cherche les informations liées à la complétion du jeu sur base de l'id du jeu
      time_to_beat = response_duration.select { |hash| hash["game_id"] == game["id"] }
      # Si on a un résultat, on remplit les infos
      if time_to_beat[0]
        game["main_story_duration"] = time_to_beat[0]["hastily"]
        game["main_extras_duration"] = time_to_beat[0]["normally"]
        game["completionist_duration"] = time_to_beat[0]["completely"]
      end

      # On ajoute des champs dévelopeurs et éditeurs au jeu
      game["developer"] = []
      game["publisher"] = []
      # On cherche les informations liées à la création du jeu sur base de l'id du jeu
      companies = response_companies.select { |hash| hash["game"] == game["id"] }
      companies.each {|company|
        # On l'ajoute en tant que développeur si il est listé en tant que tel.
        if company["developer"]
          game["developer"] << company["company"]
        # On l'ajoute en tant qu'éditeur si il est listé en tant que tel.
        elsif company["publisher"]
          game["publisher"] << company["company"]
        end
      }
    }

    @results = response.empty? ? [] : response

    respond_to do |format|
      format.turbo_stream
      format.html { render :index }
    end
  end

  def create_from_open_library
    open_library = OpenLibraryService.new
    response = open_library.search_work_by_key(params[:key])
    response_book = open_library.search_book_by_key(params[:cover_edition_key])

    if response
      # Si medium existe déjà, on le récupère(cf.doc active record)
      @medium = Medium.find_or_initialize_by(title: response["title"])
      # On met à jour les infos si besoin
      @medium.assign_attributes(
        title: response["title"],
        description: response["description"]["value"],
        release_date: Date.new(params[:year].to_i,1,1),
        year: params[:year],
        genres: response_book["subjects"].split(", "),
        poster_url: "https://covers.openlibrary.org/b/olid/#{params[:cover]}-M.jpg"
      )

      # À partir de la response, on génère un livre
      # Ensuite, on assigne ce livre à sub_media
      @medium.sub_media = Book.create_from_medium(params[:author], response_book["number_of_pages"], params[:key], params[:cover_edition_key])

      # On sauve le medium maintenant qu'il est bien remplit
      save_medium
    else
      redirect_to media_path, alert: "Medium not available."
    end
  end

  def search_from_open_library
    open_library = OpenLibraryService.new
    response = open_library.search_by_title(params[:title])

    @results = response["numFound"] > 0 ? response["docs"] : []

    respond_to do |format|
      format.turbo_stream
      format.html { render :index }
    end
  end

  def create_from_omdb
    omdb = OmdbService.new
    response = omdb.search_by_id(params[:imdb_id])

    if response["Response"] == "True"
      # Si medium existe déjà, on le récupère(cf.doc active record)
      @medium = Medium.find_or_initialize_by(title: response["Title"])

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
    else
      redirect_to media_path, alert: "Medium not available."
    end
  end

  def search_from_omdb
    omdb = OmdbService.new

    response = omdb.search_multiple(params[:title], 1)
    @results = response["Response"] == "True" ? response["Search"] : []

    # Si il y a plus de 10 films, on fait un nouveau call API pour avoir la suite
    if response["totalResults"].to_i>30
      for i in 2..3.floor
        response = omdb.search_multiple(params[:title], i)
        @results.concat(response["Search"])
      end
    elsif response["totalResults"].to_i <= 30 && response["totalResults"].to_i > 10
      for i in 2..(response["totalResults"].to_i/10).floor
        response = omdb.search_multiple(params[:title], i)
        @results.concat(response["Search"])
      end
    end

    respond_to do |format|
      format.turbo_stream
      format.html { render :index }
    end
  end

  private

  def save_medium
    # On save seulement si c'est un nouveau record
    @medium.save if @medium.new_record? || @medium.changed?

    respond_to do |format|
      format.html { redirect_to @medium, notice: "Medium added or already present" }
      format.turbo_stream { redirect_to @medium }
    end
  end

  def set_medium
    @medium = Medium.find(params[:id])
  end
end
