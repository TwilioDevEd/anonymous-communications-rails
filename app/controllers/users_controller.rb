class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def show
    @user = current_user
  end

  def create
    begin
      @user = User.create(user_params)
      # Save the user_id to the session object
      session[:user_id] = @user.id
      redirect_to verify_path
    rescue => e
      puts e.message
      render :new
    end
  end

  def show_verify
    return redirect_to new_user_path unless session[:user_id]
  end

  def verify
    @user = current_user
    if @user.verify_auth_token(params[:token])
      # Show the user profile
      redirect_to user_path(@user.id)
    else
      flash.now[:danger] = @user.errors[:verified]
      render :show_verify
    end
  end

  def resend
    current_user.send_authy_token_via_sms
    flash[:notice] = "Verification code re-sent"
    redirect_to verify_path
  end
  
  private

  def user_params
    params.require(:user).permit(
      :email, :password, :name, :country_code, :phone_number
    )
  end

end
