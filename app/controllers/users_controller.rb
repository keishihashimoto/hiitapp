class UsersController < ApplicationController
  before_action :set_team, only: [:detail]
  before_action :set_user, only: [:detail, :destroy, :show]
  before_action :admin_user?, only: [:detail, :destroy]
  def detail
    @hiit_for_user = set_hiit_for_user
  end

  def destroy
  @user.destroy
  redirect_to root_path
  end

  def show
    @today_hiit_for_user = set_today_hiit_for_user
  end

  private
  def set_team
    @team = current_user.team
  end

  def set_user
    @user = User.find(params[:id])
  end

  def set_hiit_for_user
    @group_for_user = []
    UserGroup.all.each do |user_group|
      if user_group.user_id == @user.id
        @group_for_user << user_group.group
      end
    end

    @hiit_for_user = []
    @group_for_user.each do |group_for_user|
      @hiit_for_user << group_for_user.hiit
    end
    return @hiit_for_user
  end
end
