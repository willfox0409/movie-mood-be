require 'httparty'

class TmdbService
  include HTTParty
  base_uri "https://api.themoviedb.org/3"

  def self.search_movie(title)

    response = self.get("/search/movie", query: {
      query: title, 
      api_key: ENV["TMDB_API_KEY"]
    })

    return nil unless response.success? && response["results"].present?

    response["results"].first
  end

  def self.movie_details(tmdb_id)
    response = self.get("/movie/#{tmdb_id}", query: {
      api_key: ENV["TMDB_API_KEY"]
    })

    return nil unless response.success?

    response.parsed_response
  end

  def self.full_poster_url(path)
    "https://image.tmdb.org/t/p/w500#{path}"
  end
end
