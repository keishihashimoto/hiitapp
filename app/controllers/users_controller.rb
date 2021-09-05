class UsersController < ApplicationController
  before_action :set_team, only: [:detail]
  before_action :set_user, only: [:detail, :destroy]
  before_action :admin_user?, only: [:detail, :destroy]
  def detail
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

  
end
