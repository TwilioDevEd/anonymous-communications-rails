require 'test_helper'

class VacationPropertiesControllerTest < ActionController::TestCase
  setup do
    @vacation_property = vacation_properties(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:vacation_properties)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create vacation_property" do
    assert_difference('VacationProperty.count') do
      post :create, vacation_property: { description: @vacation_property.description, image_url: @vacation_property.image_url }
    end

    assert_redirected_to vacation_property_path(assigns(:vacation_property))
  end

  test "should show vacation_property" do
    get :show, id: @vacation_property
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @vacation_property
    assert_response :success
  end

  test "should update vacation_property" do
    patch :update, id: @vacation_property, vacation_property: { description: @vacation_property.description, image_url: @vacation_property.image_url }
    assert_redirected_to vacation_property_path(assigns(:vacation_property))
  end

  test "should destroy vacation_property" do
    assert_difference('VacationProperty.count', -1) do
      delete :destroy, id: @vacation_property
    end

    assert_redirected_to vacation_properties_path
  end
end
