class TeamsController < ApplicationController
  before_action :set_team, only: [:show, :edit, :update]
  
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
      redirect_to root_path # 後でサインアップページに変更
      # デフォルトメニューの作成処理を後ほど追加
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
end
