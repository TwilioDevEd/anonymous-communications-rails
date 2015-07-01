require 'test_helper'
require 'ostruct'

class UsersControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success
    assert assigns(:user)
    assert assigns(:user).new_record?
  end

  test "should post successfully to create" do
    assert_difference "User.count" do
      puts user_params
      post :create, user: user_params
      assert_response :redirect
      assert_redirected_to home_path
    end
  end

  test "should post unsuccessfully to create" do
    assert_no_difference "User.count" do
      post :create, user: user_params(email: "blah")
      assert_response :success
      assert_template :new
      assert assigns(:user)
    end
  end

end
