class SavedMovie < ApplicationRecord
  belongs_to :user
  belongs_to :movie

  before_validation :set_title_from_movie, on: :create

  validates :title, presence: true
  validates :movie_id, uniqueness: { scope: :user_id }

  private

  def set_title_from_movie
    self.title ||= movie&.title
  end
end
