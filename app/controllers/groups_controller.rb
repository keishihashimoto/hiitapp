class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_user?, only: [:new, :create, :new_restricted, :destroy, :edit, :update]
  before_action :set_users, only: [:new, :new_restricted, :create]
  before_action :set_group, only: [:show, :destroy, :edit, :update]
  before_action :set_messages, only: [:new, :new_restricted, :create]

  def new
    @group_user_group = GroupUserGroup.new
    @enable_hiits = set_enable_hiits
  end

  def new_restricted
    @group_user_group = GroupUserGroup.new
    @enable_hiits = set_enable_hiits
    @hiit = Hiit.find(params[:hiit_id])
    enable_hiit?
  end

  def create
    @group_user_group = GroupUserGroup.new(group_params)
    if @group_user_group.valid?
      @group_user_group.save
      redirect_to team_path(current_user.team)
    else
      @enable_hiits = set_enable_hiits
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
    @enable_hiits = set_enable_hiits
    @users = set_users
    user_ids = set_user_ids
    @group_user_group = GroupUserGroup.new(name: @group.name, hiit_id: @group.hiit.id, team_id: @group.team.id, user_ids: user_ids)
    @hiit = @group.hiit
  end

  def update
    id = @group.id
    @group_user_group = GroupUserGroup.new(group_params)
    if @group_user_group.valid?
      @group_user_group.update(id)
      redirect_to group_path(@group)
    else
      @enable_hiits = set_enable_hiits
      @hiit = @group.hiit
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

  def set_enable_hiits
    @enable_hiits = []
    current_user.team.hiits.each do |hiit|
      if hiit.group == nil
        @enable_hiits << hiit
      end
    end

    return @enable_hiits
  end

  def enable_hiit?
    @hiit = Hiit.find(params[:hiit_id])
    if @hiit.group != nil
      @messages << "This HIIT is already used."
      render :new
    end
  end

end
