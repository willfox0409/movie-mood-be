class SavedMovieSerializer
  include JSONAPI::Serializer

  attributes :id, :title, :movie_id

  attribute :poster_url do |saved_movie|
    saved_movie.movie&.poster_url
  end
end