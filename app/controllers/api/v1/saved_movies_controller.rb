class Api::V1::SavedMoviesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_movie, only: [:create]
  before_action :set_saved_movie, only: [:destroy]

  def index
    saved_movies = current_user.saved_movies.includes(:movie)
    render json: SavedMovieSerializer.new(saved_movies).serializable_hash, status: :ok
  end

  def create
    # @movie is set in set_movie
    return render json: { error: "Movie not found" }, status: :not_found unless @movie

    # If it already exists for this user, return it (idempotent save)
    if (existing = current_user.saved_movies.find_by(movie_id: @movie.id))
      return render json: SavedMovieSerializer.new(existing).serializable_hash, status: :ok
    end

    saved_movie = current_user.saved_movies.create(
      movie: @movie,
      title: @movie.title
    )

    if saved_movie.persisted?
      render json: SavedMovieSerializer.new(saved_movie).serializable_hash, status: :created
    else
      render json: { error: saved_movie.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  def destroy
    @saved_movie.destroy
    head :no_content
  end

  private

  def set_movie
    Rails.logger.debug { "🔍 Raw params: #{params.inspect}" }
    Rails.logger.debug { "✅ Permitted saved_movie_params: #{saved_movie_params.inspect}" }

    # 1) Prefer explicit movie_id
    if saved_movie_params[:movie_id].present?
      @movie = Movie.find_by(id: saved_movie_params[:movie_id])
      return if @movie
      render(json: { error: "Movie not found" }, status: :not_found) and return
    end

    # 2) Fallback: accept tmdb_id and hydrate from TMDB if needed
    if saved_movie_params[:tmdb_id].present?
      tmdb_id = saved_movie_params[:tmdb_id].to_i
      @movie = Movie.find_by(tmdb_id: tmdb_id)
      return if @movie

      # Fetch details and create
      details = TmdbService.movie_details(tmdb_id)
      unless details
        render(json: { error: "Movie not found" }, status: :not_found) and return
      end

      @movie = Movie.find_or_create_by!(tmdb_id: tmdb_id) do |m|
        m.title       = details["title"] || details["name"]
        m.runtime     = details["runtime"]
        m.poster_url  = TmdbService.full_poster_url(details["poster_path"])
        m.description = details["overview"]
      end
      return
    end

    # 3) Neither movie_id nor tmdb_id provided
    render json: { error: "movie_id or tmdb_id is required" }, status: :bad_request
  end

  def set_saved_movie
    @saved_movie = current_user.saved_movies.find_by(id: params[:id])
    render(json: { error: "Saved movie not found" }, status: :not_found) unless @saved_movie
  end

  def saved_movie_params
    params.require(:saved_movie).permit(:movie_id, :tmdb_id)
  end
end