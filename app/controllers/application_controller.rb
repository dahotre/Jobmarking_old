class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user

  def not_authenticated
    redirect_to login_url, :alert => "First login to access this page."
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def require_login
    unless current_user
      not_authenticated
    end
  end

  def auto_login(user)
    session[:user_id] = user.id
  end

end
