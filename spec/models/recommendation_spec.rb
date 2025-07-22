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
end
