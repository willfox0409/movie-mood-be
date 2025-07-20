class Movie < ApplicationRecord
  has_many :recommendations 
  
  validates :tmdb_id, presence: true, uniqueness: true
  validates :title, presence: true 
end
