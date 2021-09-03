class HiitsController < ApplicationController
  before_action :admin_user?, only: [:create, :new, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_team, only: [:create, :edit, :destroy]
  before_action :set_hiit, only: [:show, :edit, :update, :destroy]
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

  def show
    @menus = set_menus_of_hiit
    @wday_list = set_hiit_dates
  end

  def edit
    date = set_hiit_dates
    menu_ids = set_menu_ids_of_hiit
    @hiit_menu_hiit = HiitMenuHiit.new(name: @hiit.name, active_time: @hiit.active_time, rest_time: @hiit.rest_time, menu_ids: menu_ids, date: date, team_id: @hiit.team.id)
  end

  def update
    id = params[:id]
    @hiit_menu_hiit = HiitMenuHiit.new(hiit_params)
    if @hiit_menu_hiit.valid?
      @hiit_menu_hiit.update(id)
      redirect_to hiit_path(@hiit)
    else
      render :edit
    end
  end

  def destroy
    @hiit.destroy
    redirect_to team_path(@team)
  end


  private
  def hiit_params
    params.require(:hiit_menu_hiit).permit(:name, :active_time, :rest_time, menu_ids: [], date: []).merge(team_id: current_user.team.id)
  end

  def set_team
    @team = current_user.team
  end

  def set_menus_of_hiit
    @menus = []
    @hiit.menu_hiits.each do |menu_hiit|
      @menus << menu_hiit.menu
    end
    return @menus
  end

  def set_menu_ids_of_hiit
    @menu_ids = []
    @menus = set_menus_of_hiit
    @menus.each do |menu|
      @menu_ids << menu.id
    end
    return @menu_ids
  end

  def set_hiit_dates
    @hiit_dates = []
    @hiit.hiit_dates.each do |hiit_date|
      @hiit_dates << hiit_date.date
    end
    return @hiit_dates
  end

  def set_hiit
    @hiit = Hiit.find(params[:id])
  end

end
