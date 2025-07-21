require 'rails_helper'

RSpec.describe "Api::V1::Recommendations", type: :request do
  describe "POST /api/v1/recommendation" do
    it "returns http success" do
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
        runtime: "under 90 min" 
      }

      # ✅ Stub OpenAI response before the request
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
              content: "Stripes"
            },
            finish_reason: "stop"
          }
        ]
      }

      stub_request(:post, "https://api.openai.com/v1/chat/completions").
        to_return(
          status: 200,
          body: openai_stub_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # ✅ Stub TMDB search
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

      stub_request(:get, /api.themoviedb.org\/3\/search\/movie/).
        to_return(
          status: 200,
          body: tmdb_search_stub.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # ✅ Stub TMDB details
      tmdb_details_stub = {
        runtime: 106
      }

      stub_request(:get, "https://api.themoviedb.org/3/movie/123")
        .with(query: { api_key: ENV["TMDB_API_KEY"] })
        .to_return(
          status: 200,
          body: tmdb_details_stub.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # ✅ Now make the request *after* stubbing
      post "/api/v1/recommendation", params: params, headers: headers

      # ✅ Expectations
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json).to have_key("data")
      expect(json["data"]).to include(
        "id",
        "type" => "movie",
        "attributes" => a_hash_including(
          "title",
          "runtime",
          "poster_url",
          "description"
        )
      )
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

      # Stub OpenAI response to return a movie that doesn't exist in TMDB
      stub_request(:post, "https://api.openai.com/v1/chat/completions").
        to_return(
          status: 200,
          body: {
            choices: [
              { message: { content: "Totally Fake Movie 9000" } }
            ]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Stub TMDB search to return an empty result
      stub_request(:get, /api.themoviedb.org\/3\/search\/movie/).
        to_return(
          status: 200,
          body: { results: [] }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      post "/api/v1/recommendation", params: {
        mood: "Surreal",
        genre: "Sci-Fi",
        decade: "2030s",
        runtime: "90"
      }, headers: headers

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)).to eq({ "error" => "Movie not found" })
    end
  end
end