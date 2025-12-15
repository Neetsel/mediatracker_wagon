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
    @conn.get("/", { t: title, apikey: @api_key, type:"movie" }).body
  end

  def search_by_id(imdb_id)
    @conn.get("/", { i: imdb_id, apikey: @api_key, type:"movie" }).body
  end

  def search_multiple(keyword, index)
    @conn.get("/", { s: keyword, apikey: @api_key, type:"movie", page:index }).body
  end

  def run(title)
    response = search_multiple(title, 1)
    @results = response["Response"] == "True" ? response["Search"] : []

    # Si il y a plus de 10 films, on fait un nouveau call API pour avoir la suite
    if response["totalResults"].to_i>30
      for i in 2..3.floor
        response = search_multiple(title, i)
        @results.concat(response["Search"])
      end
    elsif response["totalResults"].to_i <= 30 && response["totalResults"].to_i > 10
      for i in 2..(response["totalResults"].to_i/10).floor
        response = search_multiple(title, i)
        @results.concat(response["Search"])
      end
    end
    @results
  end
end
