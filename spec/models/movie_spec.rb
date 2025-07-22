require 'rails_helper'

RSpec.describe Movie, type: :model do
  describe 'associations' do
    it { should have_many(:recommendations) }
  end

  describe 'validations' do
    subject { Movie.create!(tmdb_id: 12345, title: "Example Movie") }  

    it { should validate_presence_of(:tmdb_id) }
    it { should validate_uniqueness_of(:tmdb_id) }
    it { should validate_presence_of(:title) }
  end
end
