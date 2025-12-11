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

end
