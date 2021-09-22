class UsersController < ApplicationController
  before_action :set_team, only: [:detail], if: :user_signed_in?
  before_action :set_user, only: [:detail, :destroy, :show]
  before_action :admin_user?, only: [:detail, :destroy]
  before_action :set_messages, only: [:show, :detail, :destroy]
  before_action :authenticate_user!
  def detail
    @hiit_for_user = set_hiit_for_user
  end

  def destroy
    lonely_groups = check_lonely_group
    if @lonely_groups.length >= 1
      @messages << "Since group containing this user exists, this user can't be deleted"
      @today_hiit_for_user = set_today_hiit_for_user
      @team = set_team
      render :show
    else
      @user.destroy
      @team = current_user.team
      @groups = current_user.groups
      @today_hiit_for__user = set_today_hiit_for_user
      redirect_to team_path(current_user.team)
    end
  end

  def show
    if user_signed_in? && current_user.id != @user.id && !(current_user.admin?)
      redirect_to root_path
    end

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


def check_lonely_group
  @groups_of_user = []
  UserGroup.where(user_id: @user.id).each do |group_user|
    @groups_of_user << group_user.group
  end
  @lonely_groups = []
  @groups_of_user.each do |group|
    if UserGroup.where(group_id: group.id).length == 1
      @lonely_groups << group
    end
  end
end