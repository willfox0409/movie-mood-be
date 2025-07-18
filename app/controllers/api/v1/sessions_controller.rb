class Api::V1::SessionsController < ApplicationController
  def create
    user = User.find_by(username: params[:username])

    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id)
      render json: { message: "Welcome back, #{user.username}!", token: token}, status: :ok 
    else
      render json: { error: "Invalid credentials" }, status: :unauthorized
    end
  end
end
