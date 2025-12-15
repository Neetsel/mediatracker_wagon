require 'json'

class IgdbService
  def initialize
    @client_id = ENV['IGDB_CLIENT_ID']
    @client_secret = ENV['IGDB_CLIENT_SECRET']
    @grant_type = ENV['IGDB_GRANT_TYPE']

    # Permet de s'authentifier auprès de twitch et avoir le jeton d'accès à IGDB
    @conn_auth = Faraday.new(url: "https://id.twitch.tv") do |faraday|
      faraday.request :url_encoded
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end

    @auth = @conn_auth.post("/oauth2/token", {client_id: @client_id, client_secret: @client_secret, grant_type: @grant_type}).body
    @authorization = "Bearer #{@auth["access_token"]}"
    @conn = Faraday.new(url: "https://api.igdb.com/v4/")
  end

  # On cherche les jeux sur base de leurs titres
  def search_by_title(title)
    @conn.post("games") do |req|
      req.headers['Client-ID'] = @client_id
      req.headers['Authorization'] = @authorization
      req.headers['Accept'] = 'application/json'
      req.headers['Content-Type'] = 'application/json'
      req.body = 'search "'+ title +'"; fields id,first_release_date,cover,name,platforms; limit 500; where game_type = 0 | category = 8 | category = 7;'
    end
  end

  # On cherche 1 jeu spécifique sur base de son id
  def search_by_id(id)
    @conn.post("games") do |req|
      req.headers['Client-ID'] = @client_id
      req.headers['Authorization'] = @authorization
      req.headers['Accept'] = 'application/json'
      req.headers['Content-Type'] = 'application/json'
      req.body = 'fields *; where id = '+ id +'; limit 500;'
    end
  end

  # On cherche les couvertures de jeux sur base de leurs id
  def cover_by_id(id)
    @conn.post("covers") do |req|
      req.headers['Client-ID'] = @client_id
      req.headers['Authorization'] = @authorization
      req.headers['Accept'] = 'application/json'
      req.headers['Content-Type'] = 'application/json'
      req.body = 'fields *; where id = ('+ id.join(',') +'); limit 500;'
    end
  end

  # On cherche les compagnies impliqués sur les jeux sur base de leurs id
  def involved_companies_by_id(id)
    @conn.post("involved_companies") do |req|
      req.headers['Client-ID'] = @client_id
      req.headers['Authorization'] = @authorization
      req.headers['Accept'] = 'application/json'
      req.headers['Content-Type'] = 'application/json'
      req.body = 'fields company, game, developer, publisher; where game = ('+ id.join(',') +'); limit 500;'
    end
  end

  # On cherche le détail des compagnies sur base de leurs id
  def companies_name_by_id(id)
    @conn.post("companies") do |req|
      req.headers['Client-ID'] = @client_id
      req.headers['Authorization'] = @authorization
      req.headers['Accept'] = 'application/json'
      req.headers['Content-Type'] = 'application/json'
      req.body = 'fields id, name; where id = ('+ id.join(',') +'); limit 500;'
    end
  end

  # On cherche le détail des plateformes sur base de leurs id
  def platforms_by_id(id)
    @conn.post("platforms") do |req|
      req.headers['Client-ID'] = @client_id
      req.headers['Authorization'] = @authorization
      req.headers['Accept'] = 'application/json'
      req.headers['Content-Type'] = 'application/json'
      req.body = 'fields name; where id = ('+ id.join(',') +'); limit 500;'
    end
  end

  # On cherche le détail des genres sur base de leurs id
  def genres_by_id(id)
    @conn.post("genres") do |req|
      req.headers['Client-ID'] = @client_id
      req.headers['Authorization'] = @authorization
      req.headers['Accept'] = 'application/json'
      req.headers['Content-Type'] = 'application/json'
      req.body = 'fields *; where id = ('+ id.join(',') +'); limit 500;'
    end
  end

  # On cherche le détail de la durées des jeux sur base de leurs id
  def duration_by_id(id)
    @conn.post("game_time_to_beats") do |req|
      req.headers['Client-ID'] = @client_id
      req.headers['Authorization'] = @authorization
      req.headers['Accept'] = 'application/json'
      req.headers['Content-Type'] = 'application/json'
      req.body = 'fields id,game_id,normally,hastily,completely; where game_id = ('+ id.join(',') +'); limit 500;'
    end
  end

  def run(title)
    # On fait un call API pour récupérer tous les jeux qui portent un nom similaire
    response = JSON.parse(search_by_title(title).body)

    # On prépare un array qui contient les références de toutes les covers que l on veut récupérer
    covers_id = []
    response.each {|game|
      if game["cover"]
        covers_id << game["cover"]
      end
    }

    # On prépare un array qui contient les références de tous les game_id qui nous serviront à trouver les durées de jeux et les compagnies qui ont bossé dessus
    games_id = []
    response.each {|game|
      if game["id"]
        games_id << game["id"]
      end
    }

    # On fait les calls API nécessaires pour récupérer les covers, les durées de jeux et les compagnies
    response_cover = JSON.parse(cover_by_id(covers_id).body)
    response_duration = JSON.parse(duration_by_id(games_id).body)
    response_companies = JSON.parse(involved_companies_by_id(games_id).body)

    # On modifie la réponse afin de lui ajouter les infos des 3 derniers calls API
    response.map {|game|

      # On ajoute la cover si le jeu en a une
      if game["cover"]
        # On fait le lien entre la ref de game["cover"] et notre réponse de l'API cover
        cover = response_cover.select { |hash| hash["id"] === game["cover"] }
        # l'url custom permet d'avoir l image en meilleure résolution
        game["cover"] = "//images.igdb.com/igdb/image/upload/t_720p/#{cover[0]["image_id"]}.png"
      end

      # On ajoute la date de sortie si il y en a une
      if game["first_release_date"]
        # On convertit la date reçue en Unix pour avoir l'année
        game["first_release_date"] = DateTime.strptime(game["first_release_date"].to_s, '%s').year
      end

      # On cherche les informations liées à la complétion du jeu sur base de l'id du jeu
      time_to_beat = response_duration.select { |hash| hash["game_id"] == game["id"] }
      # Si on a un résultat, on remplit les infos
      if time_to_beat[0]
        game["main_story_duration"] = time_to_beat[0]["hastily"]
        game["main_extras_duration"] = time_to_beat[0]["normally"]
        game["completionist_duration"] = time_to_beat[0]["completely"]
      end

      # On ajoute des champs dévelopeurs et éditeurs au jeu
      game["developer"] = []
      game["publisher"] = []
      # On cherche les informations liées à la création du jeu sur base de l'id du jeu
      companies = response_companies.select { |hash| hash["game"] == game["id"] }
      companies.each {|company|
        # On l'ajoute en tant que développeur si il est listé en tant que tel.
        if company["developer"]
          game["developer"] << company["company"]
        # On l'ajoute en tant qu'éditeur si il est listé en tant que tel.
        elsif company["publisher"]
          game["publisher"] << company["company"]
        end
      }
    }

    @results = response.empty? ? [] : response
    @results
  end

end
