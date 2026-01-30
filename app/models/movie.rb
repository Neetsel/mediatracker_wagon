class Movie < ApplicationRecord
  has_one :media, as: :sub_media, dependent: :destroy

  def self.initial_creation(response)
    # Si movie existe déjà, on le récupère(cf.doc active record)
    @movie = Movie.find_or_initialize_by(api_id: response["imdbID"])

    # On met à jour les infos si besoin
    @movie.assign_attributes(
      api_id: response["imdbID"]
    )

    # on sauve le film en DB
    @movie.save

    # On renvoie le film créé
    @movie
  end

  def self.create_from_medium(response)
    # Si movie existe déjà, on le récupère(cf.doc active record)
    @movie = Movie.find_or_initialize_by(api_id: response["imdbID"])

    # On met à jour les infos si besoin
    @movie.assign_attributes(
      api_id: response["imdbID"],
      actors: response["Actors"].split(", "),
      directors: response["Director"].split(", "),
      writers: response["Writer"].split(", "),
      countries: response["Country"],
      languages: response["Language"],
      runtime: response["Runtime"]
    )

    # on sauve le film en DB
    @movie.save

    # On renvoie le film créé
    @movie
  end
end
