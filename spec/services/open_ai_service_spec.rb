require 'rails_helper'
require 'webmock/rspec'

RSpec.describe OpenAiService do
  def stub_openai(status: 200, body:)
    stub_request(:post, "https://api.openai.com/v1/chat/completions")
      .to_return(status: status, body: body.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  let(:common_params) do
    {
      mood: "Never trust the gas station attendant",
      genre: "Horror",
      decade: "1970s",
      runtime_filter: "90–120 mins"
    }
  end

  describe ".recommend_movies" do
    it "returns 3 normalized items on clean JSON array" do
      content = [
        { "title" => "Deliverance", "release_year" => 1972 },
        { "title" => "The Texas Chain Saw Massacre", "release_year" => 1974 },
        { "title" => "The Hills Have Eyes", "release_year" => 1977 }
      ]
      stub_openai(body: {
        choices: [{ message: { content: content.to_json } }]
      })

      result = described_class.recommend_movies(**common_params)
      expect(result).to be_a(Hash)
      expect(result[:items]).to eq([
        { title: "Deliverance", release_year: 1972 },
        { title: "The Texas Chain Saw Massacre", release_year: 1974 },
        { title: "The Hills Have Eyes", release_year: 1977 }
      ])
      expect(result[:prompt]).to include('Return EXACTLY 3 items')
      expect(result[:full_response]).to be_present
    end

    it "handles ```json fenced response" do
      fenced = <<~TXT
        ```json
        [
          {"title":"Wrong Turn","release_year":2003},
          {"title":"Eden Lake","release_year":2008},
          {"title":"The Ritual","release_year":2017}
        ]
        ```
      TXT
      stub_openai(body: { choices: [{ message: { content: fenced } }] })

      items = described_class.recommend_movies(**common_params)[:items]
      expect(items.map { |h| h[:title] }).to eq(["Wrong Turn", "Eden Lake", "The Ritual"])
    end

    it "extracts first JSON block from messy prose" do
      messy = <<~TXT
        Here are some strong picks:
        [
          {"title":"Green Room","release_year":2015},
          {"title":"Calibre","release_year":2018},
          {"title":"Backcountry","release_year":2014}
        ]
        Enjoy.
      TXT
      stub_openai(body: { choices: [{ message: { content: messy } }] })

      items = described_class.recommend_movies(**common_params)[:items]
      expect(items.map { |h| h[:title] }).to eq(["Green Room", "Calibre", "Backcountry"])
    end

    it "returns empty items on JSON parse error" do
      stub_openai(body: { choices: [{ message: { content: "not json at all" } }] })

      result = described_class.recommend_movies(**common_params)
      expect(result[:items]).to eq([])
    end

    it "returns nil on non-success HTTP" do
      stub_openai(status: 502, body: { error: "Bad gateway" })
      expect(described_class.recommend_movies(**common_params)).to be_nil
    end

    it "returns nil on network error" do
      stub_request(:post, "https://api.openai.com/v1/chat/completions")
        .to_raise(Net::ReadTimeout.new)
      expect(described_class.recommend_movies(**common_params)).to be_nil
    end
  end

  describe ".recommend_movie" do
    it "returns a single title hash on success" do
      stub_openai(body: {
        choices: [{ message: { content: "Straw Dogs" } }]
      })

      result = described_class.recommend_movie(**common_params)
      expect(result).to match(
        title: "Straw Dogs",
        full_response: a_hash_including("choices")
      )
    end

    it "returns nil when HTTP fails" do
      stub_openai(status: 500, body: { error: "nope" })
      expect(described_class.recommend_movie(**common_params)).to be_nil
    end
  end

  describe ".generate_prompt" do
    it "includes mood/genre/decade/runtime and TMDB instruction" do
      txt = described_class.generate_prompt(**common_params)
      expect(txt).to include("mood:")
      expect(txt).to include("Genre")
      expect(txt).to include("Decade")
      expect(txt).to include("Runtime")
      expect(txt).to include("Return only the exact, full movie title")
      expect(txt).to include("TMDB")
    end
  end

  describe ".generate_prompt_multi" do
    it "asks for exactly 3 items and raw JSON array" do
      txt = described_class.generate_prompt_multi(**common_params)
      expect(txt).to include('Return EXACTLY 3 items')
      expect(txt).to include('respond ONLY with raw JSON')
      expect(txt).to include('"title": "Exact TMDB title"')
    end
  end
end