require 'httparty'

class OpenAiService
  include HTTParty
  base_uri "https://api.openai.com/v1"

  def self.recommend_movie(mood:, genre:, decade:, runtime_filter:)
    prompt = generate_prompt(mood:, genre:, decade:, runtime_filter:)

    response = post(
      "/chat/completions",
      headers: {
        "Authorization" => "Bearer #{ENV['OPENAI_API_KEY']}",
        "Content-Type" => "application/json"
      },
      body: {
        model: "gpt-4o",
        messages: [
          { role: "system", content: "You are a movie expert who recommends films based on mood and context." },
          { role: "user", content: prompt }
        ],
        temperature: 0.7
      }.to_json
    )

    return nil unless response.success?

    result = response.parsed_response
    recommended_title = result.dig("choices", 0, "message", "content")

    {
      title: recommended_title.strip,
      full_response: result
    }
  end

  def self.generate_prompt(mood:, genre:, decade:, runtime_filter:)
    """
    Recommend one movie that best fits a person experiencing the mood: #{mood}.
    Mood is the most important factor — be thoughtful and specific in your choice.

    Genre (if applicable): #{genre}
    Decade (if applicable): #{decade}s
    Runtime (if applicable): around #{runtime_filter} minutes (within 15 minutes is acceptable)

    Return only the exact, full movie title as it appears in The Movie Database (TMDB).
    Do not include quotation marks, punctuation, or extra commentary.
    Use the correct capitalization and subtitle if applicable.
    """.strip
  end

  # Method to return an array of 3 recommendations at once
  
  def self.recommend_movies(mood:, genre:, decade:, runtime_filter:)
    prompt = generate_prompt_multi(mood: mood, genre: genre, decade: decade, runtime_filter: runtime_filter)

    response = post(
      "/chat/completions",
      headers: {
        "Authorization" => "Bearer #{ENV['OPENAI_API_KEY']}",
        "Content-Type" => "application/json"
      },
      body: {
        model: "gpt-4o",
        messages: [
          { role: "system", content: "You are a movie expert who recommends films based on mood and context." },
          { role: "user", content: prompt }
        ],
        temperature: 0.7
      }.to_json
    )

    return nil unless response.success?

    result  = response.parsed_response
    content = result.dig("choices", 0, "message", "content").to_s

    items = begin
      parsed = JSON.parse(content)
      parsed.is_a?(Array) ? parsed : []
    rescue JSON::ParserError
      []
    end

    # Normalize to array of up to 3 hashes { title:, release_year: }
    normalized = items.first(3).map do |h|
      if h.is_a?(Hash)
        {
          title: h["title"].to_s.strip,
          release_year: h["release_year"].to_i
        }
      else
        # Fallback if model ignored JSON (e.g., "Movie (1999)")
        m = h.to_s.match(/(.+)\s+\((\d{4})\)/)
        next unless m
        { title: m[1].strip, release_year: m[2].to_i }
      end
    end.compact

    {
      items: normalized,       # [{ title:, release_year: }, ... up to 3]
      prompt: prompt,
      full_response: result
    }
  end

  def self.generate_prompt_multi(mood:, genre:, decade:, runtime_filter:)
    <<~TXT.strip
      You are selecting movies that match:
      - mood: "#{mood}"
      - genre: "#{genre}"
      - decade: "#{decade}"
      - runtime preference: "#{runtime_filter}"

      Return EXACTLY 3 REAL films that best fit.
      Respond ONLY with strict JSON (no prose, no markdown), as an array of objects:

      [
        { "title": "Exact TMDB title", "release_year": 1999 },
        { "title": "Exact TMDB title", "release_year": 2010 },
        { "title": "Exact TMDB title", "release_year": 1975 }
      ]

      No trailing commas. Use the original theatrical release year.
    TXT
  end
end