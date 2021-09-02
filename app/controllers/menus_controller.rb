class MenusController < ApplicationController
  before_action :admin_user?, only: [:new, :create]
  before_action :set_menu, only: [:show]
  def new
    @menu = Menu.new
  end
  
  def create
    @menu = Menu.new(menu_params)
    unless @menu.icon.attached?
      @menu.icon.attach(io: File.open(Rails.root.join("app/assets/images/no_image.jpeg")), filename: "no_image.jpeg")
    end
    if @menu.save
      redirect_to team_path(current_user.team)
    else
      render :new
    end
  end

  def show
  end

  private
  def menu_params
    params.require(:menu).permit(:name, :text, :icon).merge(team_id: current_user.team.id)
  end

  def set_menu
    @menu = Menu.find(params[:id])
  end

end
