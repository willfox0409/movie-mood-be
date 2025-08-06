require 'rails_helper'

RSpec.describe SavedMovie, type: :model do
  describe "relationships" do
    it { should belong_to(:user) }
    it { should belong_to(:movie) }
  end

  describe "validations" do
    subject { create(:saved_movie) }

    it { should validate_uniqueness_of(:movie_id).scoped_to(:user_id) }
  end
end