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
    authy = OpenStruct.new(id: '123')
    Authy::API.expects(:register_user).
      with(authy_params(user_params)).once.returns(authy)
    assert_difference "User.count" do
      post :create, user: user_params
      assert_response :redirect
      assert_redirected_to account_path
    end
  end

  test "should post unsuccessfully to create" do
    Authy::API.expects(:register_user).never
    assert_no_difference "User.count" do
      post :create, user: user_params(email: "blah")
      assert_response :success
      assert_template :new
      assert assigns(:user)
    end
  end

  def authy_params(user_params)
    {
      email: user_params[:email],
      cellphone: user_params[:phone_number],
      country_code: user_params[:country_code]
    }
  end

end
