class Book < ApplicationRecord
  has_one :media, as: :sub_media

  def self.create_from_medium(author, amount_pages, work_id, book_id)
    # Si movie existe déjà, on le récupère(cf.doc active record)
    @Book = Book.find_or_initialize_by(book_id: book_id)

    # On met à jour les infos si besoin
    @Book.assign_attributes(
      book_id: book_id,
      work_id: work_id,
      publisher: "",
      amount_pages: amount_pages,
      authors: author
    )

    # on sauve le livre en DB
    @Book.save

    # On renvoie le livre créé
    @Book
  end
end
