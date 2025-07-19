class MovieSerializer
  include JSONAPI::Serializer

  attributes :title, :runtime, :poster_url, :description
end