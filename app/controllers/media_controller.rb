class MediaController < ApplicationController
  before_action :set_medium, only: [:show]

  def index
    @media = Medium.all
  end

  def show
  end

  def create_from_igdb
    igdb = IgdbService.new
    response = JSON.parse(igdb.search_by_id(params[:id]).body)
    response_genres = JSON.parse(igdb.genres_by_id(response[0]["genres"]).body)

    genres_id = []
    response_genres.each {|genre|
      if genre["name"]
        genres_id << genre["name"]
      end
    }

    if response
      # Si medium existe déjà, on le récupère(cf.doc active record)
      @medium = Medium.find_or_initialize_by(title: response[0]["name"])

      release_date = DateTime.strptime(response[0]["first_release_date"].to_s, '%s')
      @medium.assign_attributes(
        title: response[0]["name"],
        description: response[0]["summary"],
        release_date: release_date,
        year: release_date.year,
        genres: genres_id,
        poster_url: params[:cover]
      )

      # @medium.sub_media = Game.create_from_medium()

      save_medium
    else
      redirect_to media_path, alert: "Medium not available."
    end
  end

  def search_from_igdb
    igdb = IgdbService.new
    response = JSON.parse(igdb.search_by_title(params[:title]).body)

    covers_id = []
    response.each {|game|
      if game["cover"]
        covers_id << game["cover"]
      end
    }

    response_cover = JSON.parse(igdb.cover_by_id(covers_id).body)

    response.map {|game|
      if game["cover"]
        cover = response_cover.select { |hash| hash["id"] === game["cover"] }
        game["cover"] = "//images.igdb.com/igdb/image/upload/t_720p/#{cover[0]["image_id"]}.png"
      end

      if game["first_release_date"]
        game["first_release_date"] = DateTime.strptime(game["first_release_date"].to_s, '%s').year
      end
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
    response = omdb.search_multiple(params[:title])

    @results = response["Response"] == "True" ? response["Search"] : []

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
