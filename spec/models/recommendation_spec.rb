require 'rails_helper'

RSpec.describe Recommendation, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:movie) }
  end

  describe 'validations' do
    it { should validate_presence_of(:mood) }
    it { should validate_presence_of(:genre) }
    it { should validate_presence_of(:decade) }
    it { should validate_presence_of(:runtime) }
    it { should validate_presence_of(:recommended_at) }
    it { should validate_presence_of(:openai_prompt) }
    it { should validate_presence_of(:openai_response) }
  end

  describe 'callbacks' do
    it 'sets recommended_title from associated movie before validation' do
      movie = Movie.create!(title: "No Country for Old Men", tmdb_id: 12345)
        user = User.create!(
          username: 'testuser',
          email: 'test@example.com',
          password: 'ParisTexas123',
          password_confirmation: 'ParisTexas123'
        )

      recommendation = Recommendation.create!(
        user: user,
        movie: movie,
        tmdb_id: movie.tmdb_id,
        mood: "moody",
        genre: "drama",
        decade: "2000s",
        runtime: "2h",
        recommended_at: Time.current,
        openai_prompt: "Some prompt",
        openai_response: "Some response"
      )

      expect(recommendation.recommended_title).to eq("No Country for Old Men")
    end
  end
end
