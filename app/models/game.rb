class Game < ApplicationRecord
  has_one :media, as: :sub_media

  def self.create_from_medium()
    # Si movie existe déjà, on le récupère(cf.doc active record)
    @Game = Game.find_or_initialize_by()

    # On met à jour les infos si besoin
    @Game.assign_attributes(
      book_id: book_id,
      work_id: work_id,
      publisher: "",
      amount_pages: amount_pages,
      authors: author
    )

    # on sauve le jeu en DB
    @Game.save

    # On renvoie le jeu créé
    @Game
  end
end
