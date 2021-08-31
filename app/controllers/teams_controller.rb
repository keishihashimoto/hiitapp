class TeamsController < ApplicationController
  def index
  end
  def new
    @team = Team.new
  end
  def create
    @team = Team.new(team_params)
    if @team.save
      redirect_to root_path # 後でサインアップページに変更
    else
      render :new
    end
  end

  private
  def team_params
    params.require(:team).permit(:name)
  end
end
