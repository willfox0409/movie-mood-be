class Api::V1::SavedMoviesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_movie, only: [:create]
  before_action :set_saved_movie, only: [:destroy]

  def index
    saved_movies = current_user.saved_movies.includes(:movie)
    render json: SavedMovieSerializer.new(saved_movies).serializable_hash, status: :ok
  end

  def create
    movie = Movie.find_by(id: params[:saved_movie][:movie_id])
    return render json: { error: "Movie not found" }, status: :not_found unless movie

    saved_movie = current_user.saved_movies.create(
      movie: movie,
      title: movie.title
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
    puts "🔍 Raw params: #{params.inspect}"
    puts "✅ Permitted saved_movie_params: #{saved_movie_params.inspect}"

    @movie = Movie.find_by(id: saved_movie_params[:movie_id])
    unless @movie
      render json: { error: "Movie not found" }, status: :not_found
    end
  end

  def set_saved_movie
    @saved_movie = current_user.saved_movies.find_by(id: params[:id])
    unless @saved_movie
      render json: { error: "Saved movie not found" }, status: :not_found
    end
  end

  def saved_movie_params
    params.require(:saved_movie).permit(:movie_id)
  end
end