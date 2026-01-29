class Game < ApplicationRecord
  has_one :media, as: :sub_media

  def self.create_from_medium(id, developers, publishers, platforms, story_duration, extras_duration, completionist_duration)
    
    # Si jeu existe déjà, on le récupère(cf.doc active record)
    @Game = Game.find_or_initialize_by(api_id: id)

    # On met à jour les infos si besoin
    @Game.assign_attributes(
      api_id: id,
      publisher: publishers,
      developers: developers,
      platforms: platforms,
      main_story_duration: story_duration,
      main_extras_duration: extras_duration,
      completionist_duration: completionist_duration
    )

    # on sauve le jeu en DB
    @Game.save

    # On renvoie le jeu créé
    @Game
  end
end
