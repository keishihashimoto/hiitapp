class UserHiitsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @user = User.find(params[:user_id])
    @today_hiit_for_user = set_today_hiit_for_user
  end

  def create
    if UserHiit.exists?(user_id: current_user.id, hiit_id: params[:hiit_id], done_dates: Date.today)
      UserHiit.where(user_id: current_user.id, hiit_id: params[:hiit_id], done_dates: Date.today).each do |user_hiit|
        user_hiit.destroy
      end
    else
      UserHiit.create(user_id: current_user.id, hiit_id: params[:hiit_id], done_dates: Date.today)
    end
    redirect_to action: :index
  end

end
