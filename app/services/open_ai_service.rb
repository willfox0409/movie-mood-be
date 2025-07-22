require 'httparty'

class OpenAiService
  include HTTParty
  base_uri "https://api.openai.com/v1"

  def self.recommend_movie(mood:, genre:, decade:, runtime:)
    prompt = generate_prompt(mood:, genre:, decade:, runtime:)

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

  def self.generate_prompt(mood:, genre:, decade:, runtime:)
    """
    Recommend one movie that best fits a person experiencing the mood: #{mood}.
    Mood is the most important factor — be thoughtful and specific in your choice.

    Genre (if applicable): #{genre}
    Decade (if applicable): #{decade}s
    Runtime (if applicable): around #{runtime} minutes (within 15 minutes is acceptable)

    Return only the exact, full movie title as it appears in The Movie Database (TMDB).
    Do not include quotation marks, punctuation, or extra commentary.
    Use the correct capitalization and subtitle if applicable.
  """.strip
  end
end