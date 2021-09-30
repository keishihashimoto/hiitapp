class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  #
  private
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys:[:name, :admin, :team_id])
    devise_parameter_sanitizer.permit(:account_update, keys: [:admin, :name])
  end
  def admin_user?
    unless (user_signed_in? && current_user.admin?)
      redirect_to root_path
    end
  end

  def set_hiit_for_current_user
    @group_for_current_user = []
    UserGroup.all.each do |user_group|
      if user_group.user_id == current_user.id
        @group_for_current_user << user_group.group
      end
    end

    @hiit_for_current_user = []
    @group_for_current_user.each do |group_for_current_user|
      @hiit_for_current_user << group_for_current_user.hiit
    end
    return @hiit_for_current_user
  end

  def set_today_hiit_for_current_user
    @hiit_for_current_user = set_hiit_for_current_user
    @today_hiit_for_current_user = []
    @hiit_for_current_user.each do |hiit_for_current_user|
      if HiitDate.exists?(hiit_id: hiit_for_current_user.id, date: Date.today.wday)
        @today_hiit_for_current_user << hiit_for_current_user
      end
    end
    return @today_hiit_for_current_user
  end

  def set_hiit_for_user
    @group_for_user = []
    UserGroup.all.each do |user_group|
      if user_group.user_id == @user.id
        @group_for_user << user_group.group
      end
    end

    @hiit_for_user = []
    @group_for_user.each do |group_for_user|
      @hiit_for_user << group_for_user.hiit
    end
    return @hiit_for_user
  end

  def set_today_hiit_for_user
    @hiit_for_user = set_hiit_for_user
    @today_hiit_for_user = []
    @hiit_for_user.each do |hiit_for_user|
      if HiitDate.exists?(hiit_id: hiit_for_user.id, date: Date.today.wday)
        @today_hiit_for_user << hiit_for_user
      end
    end
    return @today_hiit_for_user
  end

  def set_messages
    @messages = []
  end

end