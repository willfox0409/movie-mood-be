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
    Recommend one movie that would fit a person who is in the mood for something #{mood},
    within the #{genre} genre, from the #{decade}s, and under #{runtime} minutes if possible.
    Respond with only the exact title — no quotes or punctuation.
    """.strip
  end
end