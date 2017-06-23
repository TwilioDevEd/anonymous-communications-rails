require 'test_helper'

class ReservationsControllerTest < ActionController::TestCase
  setup do
    @host = users(:one)
    @guest = users(:two)
    @vacation_property = VacationProperty.find(reservation_params[:property_id])
    @reservation = reservations(:two)
    # Need to login user to view properties
    session[:user_id] = @host.id
  end

  teardown do
    @host.destroy
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:reservations)
  end

  test "accept or reject" do
    VCR.use_cassette("accept_or_reject_reservation") do
      post :accept_or_reject, { From: @host.phone_number, Body: "accept"}

      assert_response :success
      reservation = Reservation.find_by(id: @host.id)
      assert_not_nil(reservation.phone_number, "Reservation phone number shouldn't be nil")
      assert_equal("confirmed", reservation.status)
    end
  end

  test "create" do
    VCR.use_cassette("create_reservation", record: :new_episodes) do
      post :create, { reservation: reservation_params}

      assert_redirected_to @vacation_property
    end
  end

  test "connect host to guest sms" do
    post :connect_guest_to_host_sms, { From: @guest.phone_number, Body: "message", To: @reservation.phone_number}

    assert_response :success
    assert_equal('<?xml version="1.0" encoding="UTF-8"?><Response><Message to="+16195551234">message</Message></Response>',
      response.body)
  end

  test "connect guest to host sms" do
    post :connect_guest_to_host_sms, { From: @host.phone_number, Body: "message", To: @reservation.phone_number}

    assert_response :success
    assert_equal('<?xml version="1.0" encoding="UTF-8"?><Response><Message to="+16195559091">message</Message></Response>',
      response.body)
  end

  test "connect host to guest voice" do
    post :connect_guest_to_host_voice, { From: @guest.phone_number, Body: "message", To: @reservation.phone_number}

    assert_response :success
    assert_equal('<?xml version="1.0" encoding="UTF-8"?><Response><Play>http://howtodocs.s3.amazonaws.com/howdy-tng.mp3</Play><Dial>+16195551234</Dial></Response>',
      response.body)
  end

  test "connect guest to host voice" do
    post :connect_guest_to_host_voice, { From: @host.phone_number, Body: "message", To: @reservation.phone_number}

    assert_response :success
    assert_equal('<?xml version="1.0" encoding="UTF-8"?><Response><Play>http://howtodocs.s3.amazonaws.com/howdy-tng.mp3</Play><Dial>+16195559091</Dial></Response>',
      response.body)
  end


end
