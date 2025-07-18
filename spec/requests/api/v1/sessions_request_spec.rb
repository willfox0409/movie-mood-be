require 'rails_helper'

RSpec.describe "Api::V1::Sessions", type: :request do
  describe "POST /api/v1/login" do
    it "returns http success with valid credentials" do
      user = User.create!(
        username: 'testuser',
        email: 'test@example.com',
        password: 'ParisTexas123',
        password_confirmation: 'ParisTexas123'
      )

      post "/api/v1/login", params: {
        username: 'testuser',
        password: 'ParisTexas123'
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['message']).to eq("Welcome back, testuser!")
    end

    it 'returns an error message when password is incorrect' do 
      user = User.create!(
      username: 'testuser',
      email: 'test@example.com',
      password: 'ParisTexas123',
      password_confirmation: 'ParisTexas123'
      )

      post "/api/v1/login", params: {
      username: 'testuser',
      password: 'BerlinTexas123'
      }

      expect(response).to have_http_status(:unauthorized)
      json = JSON.parse(response.body)
      expect(json['error']).to eq("Invalid credentials")
    end

    it 'returns an error message when username does not exist' do 
      post "/api/v1/login", params: {
        username: 'missingUser',
        password: 'ParisTexas123'
      }

      expect(response).to have_http_status(:unauthorized)
      json = JSON.parse(response.body)
      expect(json['error']).to eq("Invalid credentials")
    end
  end
end
