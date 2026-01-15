class UsersController < ApplicationController
  before_action :set_user, only: %i[show update destroy]
  skip_before_action :authenticate_request, only: %i[create]

  # GET /users
  def index
    users = User.select(:id, :username, :name, :role)
    render json: users
  end

  # GET /users/search?keyword=xxx
  def search
    users = User.search(params[:keyword])
    render json: users.select(:id, :username, :name, :role)
  end

  # GET /users/roles?role=user
  def roles
    users =
      params[:role].present?
        ? User.where(role: params[:role])
        : User.all

    render json: users.select(:id, :username, :name, :role)
  end

  def show
    render json: @user.slice(:id, :username, :name, :role)
  end

  def create
    user = User.new(user_params)

    if user.save
      render json: user.slice(:id, :username, :name, :role), status: :created
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render json: @user.slice(:id, :username, :name, :role)
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    head :no_content
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :name, :password, :password_confirmation, :role)
  end
end
