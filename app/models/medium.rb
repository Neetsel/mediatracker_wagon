class Medium < ApplicationRecord
  acts_as_favoritable
  belongs_to :sub_media, polymorphic: true
  has_many :reviews
  has_many :collections
  has_many :chats

  def self.initial_movie_creation(response)
    # Si medium existe déjà, on le récupère(cf.doc active record)
    @medium = Medium.find_or_initialize_by(title: response["Title"], year: response["Year"])

    # On met à jour les infos si besoin
    @medium.assign_attributes(
      title: response["Title"],
      description: response["Plot"],
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
      year: response["first_publish_year"],
      poster_url: "https://covers.openlibrary.org/b/olid/#{response["cover_edition_key"]}-M.jpg"
    )

    @medium
  end

  def self.initial_game_creation(response)
    # Si medium existe déjà, on le récupère(cf.doc active record)
    @medium = Medium.find_or_initialize_by(title: response["name"], year: response["first_release_date"])

    @medium.assign_attributes(
      title: response["name"],
      release_date: response["release_date"],
      year: response["first_release_date"],
      poster_url: response["cover"]
    )

    @medium
  end

  def self.update_from_omdb(response)
    # Si medium existe déjà, on le récupère(cf.doc active record)
    @medium = Medium.find_or_initialize_by(title: response["Title"], year: response["Year"])

    # On met à jour les infos si besoin
    @medium.assign_attributes(
      description: response["Plot"],
      release_date: response["Released"],
      genres: response["Genre"].split(", ")
    )

    @medium
  end

  def self.update_from_open_library(response, response_book, year)
    # Si medium existe déjà, on le récupère(cf.doc active record)

    @medium = Medium.find_or_initialize_by(title: response["title"], year: year)
    response_book["subjects"] ? genres = response_book["subjects"].split(", ") : genres = []

    # On met à jour les infos si besoin
    @medium.assign_attributes(
      description: response["description"]["value"],
      release_date: Date.new(@medium.year.to_i,1,1),
      genres: genres
    )

    @medium
  end

  def self.update_from_igdb(response, genres_names, year)

    # Si medium existe déjà, on le récupère(cf.doc active record)
    @medium = Medium.find_or_initialize_by(title: response["name"], year: year)

    @medium.assign_attributes(
      description: response["summary"],
      genres: genres_names
    )

    @medium
  end


end
