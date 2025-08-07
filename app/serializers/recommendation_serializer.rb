class RecommendationSerializer
  include JSONAPI::Serializer
  attributes  :user_id,
              :mood,
              :genre,
              :decade,
              :runtime,
              :recommended_title,
              :tmdb_id,
              :openai_prompt,
              :openai_response,
              :recommended_at

  attribute :movie_id do |rec|
    rec.movie&.id
  end

  attribute :movie_title do |rec|
    rec.movie&.title
  end

  attribute :poster_url do |rec|
    rec.movie&.poster_url
  end

  attribute :description do |rec|
    rec.movie&.description
  end

  attribute :runtime_minutes do |rec|
    rec.movie&.runtime
  end
end