class Api::V1::UsersController < ApplicationController
  def create
    user = User.new(user_params)
    if user.save
      token = JsonWebToken.encode(user_id: user.id)
      render json: { message: "Account created for #{user.username}!", token: token }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:username, :email, :password)
  end
end