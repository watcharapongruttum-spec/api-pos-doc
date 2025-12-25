class ApplicationController < ActionController::API
  before_action :authenticate_request

def authenticate_request
  Rails.logger.info "AUTH HEADER => #{request.headers['Authorization'].inspect}"

  header = request.headers['Authorization']
  token = header&.split(' ')&.last

  decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
  @current_user = User.find(decoded["user_id"])
rescue => e
  Rails.logger.error "AUTH ERROR => #{e.message}"
  render json: { error: "Unauthorized" }, status: :unauthorized
end

  
end
