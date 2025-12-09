class MediaController < ApplicationController
  before_action :set_medium, only: [:show]

  def index
    @media = Medium.all
  end

  def show
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
    @media = Medium.all

    respond_to do |format|
      format.turbo_stream
      format.html { render :index }
    end
  end

  private

  def create_movie

  end

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
