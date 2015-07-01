require 'test_helper'
require 'ostruct'

class SessionsControllerTest < ActionController::TestCase
  setup do
    @user = User.create(user_params)
  end

  teardown do
    @user.destroy
  end

  test "should get login page" do
    get :login
    assert_response :success
  end

  test "should post to login_attempt successfully" do
    post :login_attempt, email: @user.email, login_password: user_params[:password]
    assert_response :redirect
    assert_redirected_to home_path
    assert_equal @user.id, session[:user_id]
  end

  test "should post to login_attempt unsuccessfully" do
    post :login_attempt, email: @user.email, login_password: "blah"
    assert_response :success
    assert_template :login
    assert_nil session[:user_id]
  end

  test "should get logout" do
    session["user_id"] = @user.id
    assert session["user_id"], "Precondition: user should be logged in"
    get :logout
    assert_response :redirect
    assert_redirected_to login_path
    assert_nil session[:user_id]
  end
end
