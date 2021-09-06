class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_user?, only: [:new, :create, :new_restricted, :destroy]
  before_action :set_users, only: [:new, :new_restricted, :create]
  before_action :set_group, only: [:show, :destroy, :edit, :update]

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

  def show
    @users = set_group_users
  end

  def destroy
    @group.destroy
    redirect_to team_path(@current_user.team)
  end

  def edit
    @users = set_users
    user_ids = set_user_ids
    @group_user_group = GroupUserGroup.new(name: @group.name, hiit_id: @group.hiit.id, team_id: @group.team.id, user_ids: user_ids)
  end

  def update
    id = @group.id
    @group_user_group = GroupUserGroup.new(group_params)
    if @group_user_group.valid?
      @group_user_group.update(id)
      redirect_to group_path(@group)
    else
      render :edit
    end
  end

  private

  def group_params
    params.require(:group_user_group).permit(:name, :hiit_id, user_ids: []).merge(team_id: current_user.team.id)
  end

  def set_users
    @users = current_user.team.users
  end

  def set_group
    @group = Group.find(params[:id])
  end

  def set_group_users
    @users = []
    @group.user_groups.each do |group_user|
      @users << group_user.user
    end
    return @users
  end

  def set_user_ids
    @users = set_group_users
    user_ids = []
    @users.each do |user|
      user_ids << user.id
    end
    return user_ids
  end

end
