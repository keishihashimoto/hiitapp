class UserHiitsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @user = User.find(params[:user_id])
    unless user_signed_in? && (current_user.admin? || current_user.id.to_s == params[:user_id])
      redirect_to root_path
    end

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
    redirect_to user_user_hiits_path(current_user)
  end

end
