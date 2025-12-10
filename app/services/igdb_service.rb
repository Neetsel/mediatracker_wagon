require 'json'

class IgdbService
  def initialize
    @client_id = ENV['IGDB_CLIENT_ID']
    @client_secret = ENV['IGDB_CLIENT_SECRET']
    @grant_type = ENV['IGDB_GRANT_TYPE']

    @conn_auth = Faraday.new(url: "https://id.twitch.tv") do |faraday|
      faraday.request :url_encoded
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end

    @auth = @conn_auth.post("/oauth2/token", {client_id: @client_id, client_secret: @client_secret, grant_type: @grant_type}).body
    @authorization = "Bearer #{@auth["access_token"]}"
    @conn = Faraday.new(url: "https://api.igdb.com/v4/")
  end

  def search_by_title(title)
    @conn.post("games") do |req|
      req.headers['Client-ID'] = @client_id
      req.headers['Authorization'] = @authorization
      req.headers['Accept'] = 'application/json'
      req.headers['Content-Type'] = 'application/json'
      req.body = 'search "'+ title +'"; fields id,first_release_date,cover,name,platforms; limit 200; where game_type = 0 | category = 8 | category = 7;'
    end
  end

  def search_by_id(id)
    @conn.post("games") do |req|
      req.headers['Client-ID'] = @client_id
      req.headers['Authorization'] = @authorization
      req.headers['Accept'] = 'application/json'
      req.headers['Content-Type'] = 'application/json'
      req.body = 'fields *; where id = '+ id +';'
    end
  end

  def cover_by_id(id)
    @conn.post("covers") do |req|
      req.headers['Client-ID'] = @client_id
      req.headers['Authorization'] = @authorization
      req.headers['Accept'] = 'application/json'
      req.headers['Content-Type'] = 'application/json'
      req.body = 'fields *; where id = ('+ id.join(',') +'); limit 200;'
    end
  end

  def companies_by_id(id)
    @conn.post("involved_companies") do |req|
      req.headers['Client-ID'] = @client_id
      req.headers['Authorization'] = @authorization
      req.headers['Accept'] = 'application/json'
      req.headers['Content-Type'] = 'application/json'
      req.body = 'fields *; where id = '+ id +';'
    end
  end

  def platforms_by_id(id)
    @conn.post("platforms") do |req|
      req.headers['Client-ID'] = @client_id
      req.headers['Authorization'] = @authorization
      req.headers['Accept'] = 'application/json'
      req.headers['Content-Type'] = 'application/json'
      req.body = 'fields *; where id = '+ id +';'
    end
  end

  def genres_by_id(id)
    @conn.post("genres") do |req|
      req.headers['Client-ID'] = @client_id
      req.headers['Authorization'] = @authorization
      req.headers['Accept'] = 'application/json'
      req.headers['Content-Type'] = 'application/json'
      req.body = 'fields *; where id = ('+ id.join(',') +');'
    end
  end

  def time_to_beat_by_id(id)
    @conn.post("game_time_to_beats") do |req|
      req.headers['Client-ID'] = @client_id
      req.headers['Authorization'] = @authorization
      req.headers['Accept'] = 'application/json'
      req.headers['Content-Type'] = 'application/json'
      req.body = 'fields *; where id = ('+ id.join(',') +');'
    end
  end

end
