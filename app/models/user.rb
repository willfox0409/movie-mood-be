class User < ApplicationRecord
  has_secure_password

  has_many :recommendations, dependent: :destroy
  has_many :saved_movies, dependent: :destroy

  validates :email, presence: true
  validates :username, presence: true 
end
