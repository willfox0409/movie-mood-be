require 'rails_helper'

RSpec.describe "Api::V1::Recommendations", type: :request do
  describe "POST /api/v1/recommendation" do
    it "returns a serialized recommendation with embedded movie data" do
      user = User.create!(
        username: 'testuser',
        email: 'test@example.com',
        password: 'ParisTexas123',
        password_confirmation: 'ParisTexas123'
      )

      post "/api/v1/login", params: {
        username: 'testuser',
        password: 'ParisTexas123'
      }

      json = JSON.parse(response.body)
      token = json["token"]

      headers = {
        "Authorization" => "Bearer #{token}"
      }

      params = {
        mood: "Cabin Fever",
        genre: "Comedy",
        decade: "1980s",
        runtime_filter: "under 90 min" 
      }

      # ✅ Stub OpenAI to return the new array format (as a STRING)
      openai_stub_response = {
        id: "chatcmpl-abc123",
        object: "chat.completion",
        created: 1234567890,
        model: "gpt-4o",  
        choices: [
          {
            index: 0,
            message: {
              role: "assistant",
              # IMPORTANT: content is a JSON array string
              content: [
                { title: "Stripes", release_year: 1981 }
              ].to_json
            },
            finish_reason: "stop"
          }
        ]
      }

      stub_request(:post, "https://api.openai.com/v1/chat/completions")
        .to_return(
          status: 200,
          body: openai_stub_response.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      # ✅ Use runtime_filter to match controller
      params = {
        mood: "Cabin Fever",
        genre: "Comedy",
        decade: "1980s",
        runtime_filter: "under 90 min"
      }

      # TMDB search stub stays the same
      tmdb_search_stub = {
        results: [
          {
            id: 123,
            title: "Stripes",
            overview: "Two friends who are dissatisfied with their jobs decide to join the army.",
            poster_path: "/stripes_poster.jpg"
          }
        ]
      }
      stub_request(:get, /api\.themoviedb\.org\/3\/search\/movie/)
        .to_return(status: 200, body: tmdb_search_stub.to_json, headers: { "Content-Type" => "application/json" })

      # TMDB details stub (runtime, etc.)
      tmdb_details_stub = { runtime: 106 }
      stub_request(:get, %r{https://api\.themoviedb\.org/3/movie/123\?api_key=.*})
        .to_return(status: 200, body: tmdb_details_stub.to_json, headers: { "Content-Type" => "application/json" })

      post "/api/v1/recommendations", params: params, headers: headers
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      # top-level type changed
      expect(json["data"]).to include("type" => "recommendation_batch")

      attrs = json["data"]["attributes"]
      expect(attrs).to include("choices", "primary_recommendation_id")

      # choices array with enriched movie fields
      expect(attrs["choices"]).to be_an(Array)
      first = attrs["choices"].first

      expect(first).to include(
        "title" => "Stripes",
        "release_year" => 1981,
        "runtime_minutes" => 106,
        "poster_url" => "https://image.tmdb.org/t/p/w500/stripes_poster.jpg",
        "description" => "Two friends who are dissatisfied with their jobs decide to join the army.",
        "tmdb_id" => 123
      )

      # movie_id is created in your DB — presence check is enough
      expect(first).to have_key("movie_id")
    end

    it "returns 404 if TMDB cannot find the movie" do
      user = User.create!(
        username: 'testuser3',
        email: 'notfound@example.com',
        password: 'ParisTexas123',
        password_confirmation: 'ParisTexas123'
      )

      post "/api/v1/login", params: {
        username: 'testuser3',
        password: 'ParisTexas123'
      }

      token = JSON.parse(response.body)["token"]
      headers = { "Authorization" => "Bearer #{token}" }

      # ✅ OpenAI returns a valid array string with a fake title
      stub_request(:post, "https://api.openai.com/v1/chat/completions")
        .to_return(
          status: 200,
          body: {
            choices: [
              { message: { content: [{ title: "Totally Fake Movie 9000", release_year: 2033 }].to_json } }
            ]
          }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      # ✅ TMDB returns no hits → should produce 404
      stub_request(:get, /api\.themoviedb\.org\/3\/search\/movie/)
        .to_return(status: 200, body: { results: [] }.to_json, headers: { "Content-Type" => "application/json" })

      post "/api/v1/recommendations", params: {
        mood: "Surreal",
        genre: "Sci-Fi",
        decade: "2030s",
        runtime_filter: "90"
      }, headers: headers

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)).to eq({ "error" => "No matching movies found" })
    end
  end
end
