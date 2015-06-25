class SessionsController < ApplicationController
  before_filter :authenticate_user, :except => [:login, :login_attempt]
  before_filter :save_login_state, :only => [:login, :login_attempt]

  def login
    #Login Form
  end

  def login_attempt
    user = User.find_by_email(params[:email])
    authorized_user = user.authenticate(params[:login_password])
    if authorized_user
      session[:user_id] = authorized_user.id
      flash[:notice] = "Wow Welcome again, you logged in as #{authorized_user.email}"
      redirect_to home_path


    else
      flash[:notice] = "Invalid Username or Password"
      render "login"  
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to :action => 'login'
  end

end