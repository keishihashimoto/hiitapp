class MenusController < ApplicationController
  before_action :admin_user?, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_menu, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:show]
  before_action :set_messages, only: [:show, :destroy]
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
    @hiits = set_related_hiits
  end

  def edit
  end

  def update
    if @menu.update(menu_params)
      redirect_to menu_path(@menu)
    else
      render :edit
    end
  end

  def destroy
    if MenuHiit.exists?(menu_id: @menu.id)
      @messages << "Since hiit using this menu exists, this menu can't be deleted."
      @hiits = set_related_hiits
      render :show
    else
      redirect_to team_path(current_user.team)
      @menu.destroy
    end
  end

  private
  def menu_params
    params.require(:menu).permit(:name, :text, :icon).merge(team_id: current_user.team.id)
  end

  def set_menu
    @menu = Menu.find(params[:id])
  end

  def set_related_hiits
    @hiits = []
    menu_hiits = []
    Hiit.all.each do |hiit|
      menu_hiit = MenuHiit.where(hiit_id: hiit.id, menu_id: @menu.id)[0]
      if menu_hiit != nil
        menu_hiits << menu_hiit
      end
    end
    menu_hiits.each do |menu_hiit|
      @hiits << menu_hiit.hiit
    end
    return @hiits
  end

end
