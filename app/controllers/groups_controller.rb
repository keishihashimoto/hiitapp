class GroupsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :new_restricted]
  before_action :admin_user?, only: [:new, :create, :new_restricted]
  before_action :set_users, only: [:new, :new_restricted, :create]

  def new
    @group_user_group = GroupUserGroup.new
    @hiits = current_user.team.hiits
  end

  def new_restricted
    @group_user_group = GroupUserGroup.new
    @hiits = current_user.team.hiits
    @hiit = Hiit.find(params[:hiit_id])
  end

  def create
    @group_user_group = GroupUserGroup.new(group_params)
    if @group_user_group.valid?
      @group_user_group.save
      redirect_to team_path(current_user.team)
    else
      render :new
    end
  end

  def group_params
    params.require(:group_user_group).permit(:name, :hiit_id, user_ids: []).merge(team_id: current_user.team.id)
  end

  def set_users
    @users = current_user.team.users
  end

end
