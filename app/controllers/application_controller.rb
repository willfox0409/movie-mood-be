class ApplicationController < ActionController::API
  def current_user
    auth_header = request.headers['Authorization']
    token = auth_header.split(' ').last if auth_header.present?
    decoded = JsonWebToken.decode(token)

    if decoded
      @current_user ||= User.find_by(id: decoded[:user_id])
    end
  end

  def authenticate_user!
    render json: { error: "Not Authorized" }, status: :unauthorized unless current_user
  end
end
