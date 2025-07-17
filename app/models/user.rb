class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true
  validates :username, presence: true 
end
