class Book < ApplicationRecord
  has_one :media, as: :sub_media

  def self.initial_creation(response)
    # Si livre existe déjà, on le récupère(cf.doc active record)
    @Book = Book.find_or_initialize_by(book_id: response["cover_edition_key"])

    # On met à jour les infos si besoin
    @Book.assign_attributes(
      book_id: response["cover_edition_key"],
      authors: response["author_name"]
    )

    # on sauve le livre en DB
    @Book.save

    # On renvoie le livre créé
    @Book
  end

  def self.create_from_medium(cover_edition_key, key, amount_pages, author_name)
    # Si livre existe déjà, on le récupère(cf.doc active record)
    @Book = Book.find_or_initialize_by(book_id: cover_edition_key)

    # On met à jour les infos si besoin
    @Book.assign_attributes(
      book_id: cover_edition_key,
      work_id: key,
      publisher: "",
      amount_pages: amount_pages,
      authors: author_name
    )

    # on sauve le livre en DB
    @Book.save

    # On renvoie le livre créé
    @Book
  end
end
