class TeamsController < ApplicationController
  before_action :set_team, only: [:show, :edit, :update]
  before_action :authenticate_user!, only: [:show, :edit, :update]
  before_action :get_root, only: [:new]
  def index
    if user_signed_in?
      @team = current_user.team
    end
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)
    if @team.save
      # デフォルトメニューの作成処理
      create_default_menu
      redirect_to new_user_registration_path
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @team.update(team_params)
      redirect_to team_path(@team)
    else
      render :edit
    end
  end

  private

  def team_params
    params.require(:team).permit(:name)
  end

  def set_team
    @team = Team.find(params[:id])
  end

  def get_root
    if user_signed_in?
      redirect_to root_path
    end
  end

  def create_default_menu
    menu1 = Menu.create(name: "腕立て伏せ", team_id: @team.id)
    menu1.icon.attach(io: File.open(Rails.root.join("app/assets/images/pushup.png")), filename: "pushup.png")
    menu2 = Menu.create(name: "スクワット", team_id: @team.id)
    menu2.icon.attach(io: File.open(Rails.root.join("app/assets/images/squat.png")), filename: "squat.png")
    menu3 = Menu.create(name: "プランク", team_id: @team.id)
    menu3.icon.attach(io: File.open(Rails.root.join("app/assets/images/frontbridge.png")), filename: "frontbridge.png")
    menu4 = Menu.create(name: "懸垂", team_id: @team.id)
    menu4.icon.attach(io: File.open(Rails.root.join("app/assets/images/pullup.png")), filename: "pullup.png")
  end
end
