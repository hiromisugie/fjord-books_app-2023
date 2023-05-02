class UsersController < ApplicationController
  def index
    @users = User.all.order(:id).page(params[:page])
  end

  def show
    @user = User.find(params[:id])
  end
end
