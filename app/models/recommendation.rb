class Recommendation < ApplicationRecord
  belongs_to :user
  belongs_to :movie

  validates :mood, presence: true
  validates :genre, presence: true
  validates :decade, presence: true
  validates :runtime, presence: true
  validates :recommended_at, presence: true
  validates :openai_prompt, presence: true
  validates :openai_response, presence: true
end
