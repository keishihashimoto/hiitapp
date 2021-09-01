class UsersController < ApplicationController
  before_action :set_team, only: [:index]
  before_action :set_user, only: [:index, :destroy]
  before_action :admin_user?, only: [:index]
  def index
  end

  def destroy
  @user.destroy
  redirect_to root_path
  end
  private
  def set_team
    @team = current_user.team
  end

  def set_user
    @user = User.find(params[:id])
  end

  def admin_user?
    unless current_user.admin?
      redirect_to root_path
    end
  end
end
