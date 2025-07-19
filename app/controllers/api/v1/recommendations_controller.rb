class Api::V1::RecommendationsController < ApplicationController
  before_action :authenticate_user!

  def create
    # Step 1: Accept parameters
    mood    = params[:mood]
    genre   = params[:genre]
    decade  = params[:decade]
    runtime = params[:runtime]

    # Step 2: Call OpenAIService
    ai_result = OpenAiService.recommend_movie(mood: mood, genre: genre, decade: decade, runtime: runtime)
    # puts "🎥 AI returned title: #{ai_result[:title]}"
    # puts "🧠 Full OpenAI response: #{ai_result[:full_response]}"
    movie_title = ai_result[:title].gsub(/\A"|"\Z/, '').strip
    full_response = ai_result[:full_response]

    # Step 3: Check if movie exists in DB, otherwise fetch from TMDB
    movie = Movie.find_by(title: movie_title)

    if movie.nil?
      puts "🔎 Cleaned title being searched: #{movie_title.inspect}"
      tmdb_data = TmdbService.search_movie(movie_title)

      puts "🧪 TMDB search response: #{tmdb_data.inspect}"               # ✅ Correct!

      if tmdb_data.nil?
        render json: { error: "Movie not found" }, status: :not_found and return
      end

      puts "🎬 TMDB ID we're about to look up: #{tmdb_data["id"].inspect}"
      puts "🎞️ Full tmdb_data: #{tmdb_data.inspect}"
      details = TmdbService.movie_details(tmdb_data["id"])

      movie = Movie.create!(
        title: tmdb_data["title"],
        tmdb_id: tmdb_data["id"],
        runtime: details["runtime"],
        poster_url: TmdbService.full_poster_url(tmdb_data["poster_path"]),
        description: tmdb_data["overview"]
      )
    end

    # Step 4: Create a Recommendation record
    Recommendation.create!(
      user: current_user,
      movie: movie,
      tmdb_id: movie.tmdb_id,
      mood: mood,
      genre: genre,
      decade: decade,
      runtime: runtime,
      recommended_at: Time.current,
      openai_prompt: OpenAiService.generate_prompt(mood: mood, genre: genre, decade: decade, runtime: runtime),
      openai_response: full_response
    )

    # Step 5: Return the serialized movie
    render json: MovieSerializer.new(movie), status: :ok
  end
end