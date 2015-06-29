class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def show
    @user = current_user
  end

  def create
    @user = User.create(user_params)
    puts @user.valid?
    if @user.valid?
      # Save the user_id to the session object
      session[:user_id] = @user.id
      redirect_to home_path
    else 
      render :new
      puts @user.errors.full_messages
      flash.now[:danger] = @user.errors.full_messages
    end
  end
  
  private

  def user_params
    params.require(:user).permit(
      :email, :password, :name, :country_code, :phone_number
    )
  end

end
