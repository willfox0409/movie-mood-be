class Movie < ApplicationRecord
  has_many :recommendations
  has_many :saved_movies, dependent: :nullify
  
  validates :tmdb_id, presence: true
  validates :title, presence: true 
end
