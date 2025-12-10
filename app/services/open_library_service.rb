require 'json'

class OpenLibraryService
  def initialize
    @conn = Faraday.new(url: "https://openlibrary.org") do |faraday|
      faraday.request :url_encoded
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end
  end

  def search_by_title(title)
    @conn.get("/search.json", { title: title }).body
  end

  def search_work_by_key(key)
    @conn.get("#{key}.json").body
  end

  def search_book_by_key(key)
    @conn.get("/books/#{key}.json").body
  end

  def search_by_author(author)
    @conn.get("/search/authors.json", { q: author }).body
  end
end
