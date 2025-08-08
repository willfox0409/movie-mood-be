class Api::V1::RecommendationsController < ApplicationController
  def create
    # 1) Accept parameters
    mood    = params[:mood]
    genre   = params[:genre]
    decade  = params[:decade]
    runtime = params[:runtime_filter] || params[:runtime]

    # 2) Call OpenAI for THREE candidates (title + release_year)
    ai = OpenAiService.recommend_movies(
      mood: mood,
      genre: genre,
      decade: decade,
      runtime_filter: runtime
    )
    return render json: { error: "OpenAI request failed" }, status: :bad_gateway if ai.nil?

    candidates = ai[:items]
    if candidates.blank?
      return render json: { error: "No candidates returned" }, status: :bad_gateway
    end

    # 3) Enrich each candidate via TMDB (query + year)
    enriched = candidates.map do |cand|
      next if cand[:title].blank? || cand[:release_year].to_i <= 0

      hit = TmdbService.search_movie_with_year(cand[:title], cand[:release_year])
      next unless hit

      details = TmdbService.movie_details(hit["id"])
      {
        title: hit["title"],
        release_year: cand[:release_year],
        tmdb_id: hit["id"],
        poster_url: TmdbService.full_poster_url(hit["poster_path"]),
        description: hit["overview"],
        runtime_minutes: details&.dig("runtime")
      }
    end.compact

    if enriched.blank?
      return render json: { error: "No matching movies found" }, status: :not_found
    end

    # 4) Persist ONLY the first enriched item (MVP)
    primary = enriched.first
    movie = Movie.find_or_create_by!(tmdb_id: primary[:tmdb_id]) do |m|
      m.title = primary[:title]
      m.runtime = primary[:runtime_minutes]
      m.poster_url = primary[:poster_url]
      m.description = primary[:description]
    end

    recommendation = Recommendation.new(
      user: current_user,
      movie: movie,
      tmdb_id: movie.tmdb_id,
      mood: mood,
      genre: genre,
      decade: decade,
      runtime: runtime,
      recommended_at: Time.current,
      openai_prompt: OpenAiService.generate_prompt_multi(mood: mood, genre: genre, decade: decade, runtime_filter: runtime),
      openai_response: ai[:full_response]
    )

    unless recommendation.save
      puts recommendation.errors.full_messages
      return render json: { error: "Recommendation could not be created", details: recommendation.errors.full_messages }, status: :unprocessable_entity
    end

    # 5) Return the batch so FE can step through by index
    render json: {
      data: {
        type: "recommendation_batch",
        id: recommendation.id.to_s,
        attributes: {
          primary_recommendation_id: recommendation.id,
          choices: enriched
        }
      }
    }, status: :ok
  end
end