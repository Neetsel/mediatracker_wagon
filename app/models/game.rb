class Game < ApplicationRecord
  has_one :media, as: :sub_media

  def self.initial_creation(response)
    # Si livre existe déjà, on le récupère(cf.doc active record)
    @game = Game.find_or_initialize_by(api_id: response["id"])

    # On met à jour les infos si besoin
    @game.assign_attributes(
      api_id: response["id"],
      publishers_ref: response["publisher"],
      developers_ref: response["developer"],
      platforms_ref: response["platforms"],
      main_story_duration: response["main_story_duration"],
      main_extras_duration: response["main_extras_duration"],
      completionist_duration: response["completionist_duration"]
    )

    # on sauve le livre en DB
    @game.save

    # On renvoie le livre créé
    @game
  end

  def self.update(response, developers, publishers, platforms)

    # Si jeu existe déjà, on le récupère(cf.doc active record)
    @game = Game.find_or_initialize_by(api_id: response["id"])

    # On met à jour les infos si besoin
    @game.assign_attributes(
      publisher: publishers,
      developers: developers,
      platforms: platforms,
    )

    # on sauve le jeu en DB
    @game.save

    # On renvoie le jeu créé
    @game
  end
end
