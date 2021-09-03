class GroupsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]
  before_action :admin_user?, only: [:new, :create]

  def new
    @group_user_group = GroupUserGroup.new
    @hiits = current_user.team.hiits
    @users = @current_user.team.users
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

end
