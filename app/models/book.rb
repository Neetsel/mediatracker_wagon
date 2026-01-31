class Book < ApplicationRecord
  has_one :media, as: :sub_media

  def self.initial_creation(response)
    # Si livre existe déjà, on le récupère(cf.doc active record)
    @book = Book.find_or_initialize_by(book_id: response["cover_edition_key"])

    # On met à jour les infos si besoin
    @book.assign_attributes(
      work_id: response["key"],
      book_id: response["cover_edition_key"],
      authors: response["author_name"]
    )

    # on sauve le livre en DB
    @book.save
    # On renvoie le livre créé
    @book
  end

  def self.update(response, response_book)
    # Si livre existe déjà, on le récupère(cf.doc active record)
    @book = Book.find_or_initialize_by(book_id: @book.book_id)

    # On met à jour les infos si besoin
    @book.assign_attributes(
      publisher: "",
      amount_pages: response_book["number_of_pages"]
    )

    # on sauve le livre en DB
    @book.save

    # On renvoie le livre créé
    @book
  end
end
