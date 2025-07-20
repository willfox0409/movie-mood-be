class RecommendationSerializer
  include JSONAPI::Serializer
  attributes :user_id,
              :mood,
              :genre,
              :decade,
              :runtime,
              :recommended_title,
              :tmdb_id,
              :openai_prompt,
              :openai_response,
              :recommended_at
end
