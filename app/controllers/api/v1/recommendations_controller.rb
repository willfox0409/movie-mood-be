class Api::V1::RecommendationsController < ApplicationController
  def create
    # 1. Accept user parameters (mood, genre, etc.)
    # 2. Send those to OpenAI — get a movie title back
    # 3. Look for that movie in your DB. If it doesn’t exist, fetch from TMDB & save
    movie = Movie.find_or_create_by(title: ai_movie_title) do |m|
      # m.tmdb_id = ...
      # m.runtime = ...
      # m.poster_url = ...
    end

    # 4. Save a new Recommendation for this user and this prompt
    Recommendation.create!(
      user: current_user,
      movie: movie,
      mood: params[:mood],
      genre: params[:genre],
      decade: params[:decade],
      runtime: params[:runtime],
      openai_response: full_response_text,
      recommended_at: Time.now,
      openai_prompt: generated_prompt_string,
      openai_response: llm_response_text
    )

    render json: MovieSerializer.new(movie), status: :ok
  end
end