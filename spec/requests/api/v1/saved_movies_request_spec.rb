require 'rails_helper'

RSpec.describe "Api::V1::SavedMovies", type: :request do
  let!(:user) { create(:user, password: 'ParisTexas123', password_confirmation: 'ParisTexas123') }
  let!(:movie) { create(:movie, title: "Hereditary") }
  let!(:headers) do
    post "/api/v1/login", params: { username: user.username, password: 'ParisTexas123' }
    token = JSON.parse(response.body)["token"]
    { "Authorization" => "Bearer #{token}" }
  end

  describe "GET /api/v1/saved_movies" do
    it "returns all saved movies for the user" do
      create(:saved_movie, user: user, movie: movie, title: movie.title)

      get "/api/v1/saved_movies", headers: headers

      expect(JSON.parse(response.body)["data"].length).to eq(1)
      expect(JSON.parse(response.body)["data"].first["attributes"]["title"]).to eq(movie.title)
    end
  end

  describe "POST /api/v1/saved_movies" do
    it "saves a movie for the user" do
      post "/api/v1/saved_movies", params: { movie_id: movie.id }, headers: headers

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["data"]["attributes"]["title"]).to eq(movie.title)
    end

    it "returns 404 if movie not found" do
      post "/api/v1/saved_movies", params: { movie_id: -1 }, headers: headers

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["error"]).to eq("Movie not found")
    end
  end

  describe "DELETE /api/v1/saved_movies/:id" do
    it "removes a saved movie" do
      saved_movie = create(:saved_movie, user: user, movie: movie)

      delete "/api/v1/saved_movies/#{saved_movie.id}", headers: headers

      expect(response).to have_http_status(:no_content)
      expect(SavedMovie.exists?(saved_movie.id)).to be_falsey
    end
  end
end