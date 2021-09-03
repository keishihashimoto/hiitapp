class HiitsController < ApplicationController
  before_action :admin_user?, only: [:create, :new]
  before_action :authenticate_user!, only: [:new, :create]
  before_action :set_team, only: [:create]
  def new
    @hiit_menu_hiit = HiitMenuHiit.new
  end
  
  def create
    @hiit_menu_hiit = HiitMenuHiit.new(hiit_params)
    if @hiit_menu_hiit.valid?
      @hiit_menu_hiit.save
      redirect_to team_path(@team)
    else
      render :new
    end
  end

  private
  def hiit_params
    params.require(:hiit_menu_hiit).permit(:name, :active_time, :rest_time, menu_ids: [], date: []).merge(team_id: current_user.team.id)
  end

  def set_team
    @team = current_user.team
  end

end
