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
      post "/api/v1/saved_movies", params: { saved_movie: { movie_id: movie.id } }, headers: headers

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["data"]["attributes"]["title"]).to eq(movie.title)
    end

    it "returns 404 if movie not found" do
      post "/api/v1/saved_movies", params: { saved_movie: { movie_id: -1 } }, headers: headers

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

  describe "POST /api/v1/saved_movies (tmdb + edge cases)" do
    let(:tmdb_id) { 4455 }

    it "creates via tmdb_id when the Movie does not exist (hydrates from TMDB)" do
      # stub TMDB lookups
      details = {
        "title" => "Coherence",
        "runtime" => 89,
        "poster_path" => "/coherence.jpg",
        "overview" => "Dinner party multiverse."
      }
      allow(TmdbService).to receive(:movie_details).with(tmdb_id).and_return(details)
      allow(TmdbService).to receive(:full_poster_url).with("/coherence.jpg")
        .and_return("https://image.tmdb.org/t/p/w500/coherence.jpg")

      expect {
        post "/api/v1/saved_movies",
          params: { saved_movie: { tmdb_id: tmdb_id } },
          headers: headers
      }.to change(Movie, :count).by(1).and change(SavedMovie, :count).by(1)

      expect(response).to have_http_status(:created)
      body = response.parsed_body
      expect(body.dig("data", "attributes", "title")).to eq("Coherence")
    end

    it "reuses existing Movie when posting tmdb_id for a movie already in DB" do
      existing = create(:movie, tmdb_id: tmdb_id, title: "Coherence")
      # Should not hit TMDB at all
      expect(TmdbService).not_to receive(:movie_details)

      expect {
        post "/api/v1/saved_movies",
          params: { saved_movie: { tmdb_id: tmdb_id } },
          headers: headers
      }.to change(Movie, :count).by(0).and change(SavedMovie, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(SavedMovie.last.movie_id).to eq(existing.id)
    end

    it "is idempotent: posting the same movie twice returns 200 and does not duplicate" do
      # first save by movie_id
      post "/api/v1/saved_movies",
        params: { saved_movie: { movie_id: movie.id } },
        headers: headers
      expect(response).to have_http_status(:created)

      # second save should return 200 OK and not create another row
      expect {
        post "/api/v1/saved_movies",
          params: { saved_movie: { movie_id: movie.id } },
          headers: headers
      }.not_to change(SavedMovie, :count)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig("data","attributes","title")).to eq("Hereditary")
    end

    it "returns 404 when tmdb_id is provided but TMDB returns nil" do
      allow(TmdbService).to receive(:movie_details).with(tmdb_id).and_return(nil)

      post "/api/v1/saved_movies",
        params: { saved_movie: { tmdb_id: tmdb_id } },
        headers: headers

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["error"]).to eq("Movie not found")
    end

    it "returns 400 when neither movie_id nor tmdb_id is provided" do
      post "/api/v1/saved_movies",
        params: { saved_movie: {} },
        headers: headers

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body["error"]).to eq("movie_id or tmdb_id is required")
    end
  end

  describe "DELETE /api/v1/saved_movies/:id (edge)" do
    it "returns 404 if the saved movie is not found" do
      delete "/api/v1/saved_movies/999999", headers: headers
      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["error"]).to eq("Saved movie not found")
    end
  end
end