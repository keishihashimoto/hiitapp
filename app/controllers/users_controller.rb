class UsersController < ApplicationController
  before_action :set_team
  before_action :admin_user?, only: [:index]
  def index
    @user = User.find(params[:id])
  end

  private
  def set_team
    @team = current_user.team
  end

  def admin_user?
    unless current_user.admin?
      redirect_to root_path
    end
  end
end
