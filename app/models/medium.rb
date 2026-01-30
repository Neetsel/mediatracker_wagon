class Medium < ApplicationRecord
  acts_as_favoritable
  belongs_to :sub_media, polymorphic: true
  has_many :reviews
  has_many :collections
  has_many :chats

  def self.initial_movie_creation(response)
    # Si medium existe déjà, on le récupère(cf.doc active record)
    @medium = Medium.find_or_initialize_by(title: response["Title"], release_date: response["Released"])

    # On met à jour les infos si besoin
    @medium.assign_attributes(
      title: response["Title"],
      description: response["Plot"],
      release_date: response["Released"],
      year: response["Year"],
      poster_url: response["Poster"]
    )

    @medium
  end

  def self.initial_book_creation(response)
    # Si medium existe déjà, on le récupère(cf.doc active record)
    @medium = Medium.find_or_initialize_by(title: response["title"], year: response["first_publish_year"])

    # On met à jour les infos si besoin
    @medium.assign_attributes(
      title: response["title"],
      release_date: Date.new(response["first_publish_year"].to_i,1,1),
      year: response["first_publish_year"],
      poster_url: "https://covers.openlibrary.org/b/olid/#{response["cover_edition_key"]}-M.jpg"
    )

    @medium
  end

  def self.initial_game_creation(response)
    # On convertit la date reçue en Unix
    release_date = DateTime.strptime(response["first_release_date"].to_s, '%s')

    # Si medium existe déjà, on le récupère(cf.doc active record)
    @medium = Medium.find_or_initialize_by(title: response["name"], release_date: release_date)

    @medium.assign_attributes(
      title: response["name"],
      release_date: release_date,
      year: release_date.year,
      poster_url: response["cover"]
    )

    @medium
  end

  def self.create_from_omdb(response)
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

    @medium
  end

  def self.create_from_open_library(response, first_publish_year, cover_edition_key, genres)
    # Si medium existe déjà, on le récupère(cf.doc active record)
    @medium = Medium.find_or_initialize_by(title: response["title"], year: first_publish_year)

    # On met à jour les infos si besoin
    @medium.assign_attributes(
      title: response["title"],
      description: response["description"]["value"],
      release_date: Date.new(first_publish_year.to_i,1,1),
      year: first_publish_year,
      genres: genres,
      poster_url: "https://covers.openlibrary.org/b/olid/#{cover_edition_key}-M.jpg"
    )

    @medium
  end

  def self.create_from_igdb(response, genres_names, cover)
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
      poster_url: cover
    )

    @medium
  end


end
