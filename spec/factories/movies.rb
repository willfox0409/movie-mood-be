FactoryBot.define do
  factory :movie do
    tmdb_id { "12345" }
    title { "Test Movie" }
    runtime { 100 }
    poster_url { "https://example.com/poster.jpg" }
    description { "A test movie description." }
  end
end