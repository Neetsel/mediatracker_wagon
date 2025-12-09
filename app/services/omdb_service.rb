require 'json'

class OmdbService
  def initialize
    @api_key = ENV['OMDB_API_KEY']
    @conn = Faraday.new(url: "https://www.omdbapi.com") do |faraday|
      faraday.request :url_encoded
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end
  end

  def search_by_title(title)
    @conn.get("/", { t: title, apikey: @api_key }).body
  end

  def search_by_id(imdb_id)
    @conn.get("/", { i: imdb_id, apikey: @api_key }).body
  end

  def search_multiple(keyword)
    @conn.get("/", { s: keyword, apikey: @api_key }).body
  end

end
