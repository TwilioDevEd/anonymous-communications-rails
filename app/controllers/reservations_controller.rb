class ReservationsController < ApplicationController
  skip_before_filter  :verify_authenticity_token, only: [:accept_or_reject, :connect_guest_to_host_sms]

  # GET /vacation_properties/new
  def new
    @reservation = Reservation.new
  end

  def create
    @vacation_property = VacationProperty.find(params[:reservation][:property_id])
    @reservation = @vacation_property.reservations.create(reservation_params)

    if @reservation.save
      flash[:notice] = "Sending your reservation request now."
      @reservation.host.check_for_reservations_pending
      redirect_to @vacation_property
    else
      flast[:danger] = @reservation.errors
    end
  end

  # webhook for twilio incoming message from host
  def accept_or_reject
    incoming = Sanitize.clean(params[:From]).gsub(/^\+\d/, '')
    sms_input = params[:Body].downcase
    begin
      @host = User.find_by(phone_number: incoming)
      @reservation = @host.pending_reservation

      if sms_input == "accept" || sms_input == "yes"
        @reservation.confirm!
      else
        @reservation.reject!
      end

      @host.check_for_reservations_pending

      sms_reponse = "You have successfully #{@reservation.status} the reservation."
      respond(sms_reponse)
    rescue Exception => e
      puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ERROR: #{e.message}"
      sms_reponse = "Sorry, it looks like you don't have any reservations to respond to."
      respond(sms_reponse)
    end
  end

  # webhook for twilio to anonymously connect the two parties
  def connect_guest_to_host_sms
    incoming_phone = Sanitize.clean(params[:From]).gsub(/^\+\d/, '')
    message = params[:Body]
    anonymous_phone_number = params[:To]

    @reservation = Reservation.where(phone_number: anonymous_phone_number).first

    # Guest -> Host
    if @reservation.guest.phone_number == incoming_phone
      puts "Guest -> Host"
      @reservation.send_message_to_host(message)

    # Host -> Guest
    elsif @reservation.host.phone_number == incoming_phone
      puts "Host -> Guest"
      @reservation.send_message_to_guest(message)
    end
    render text: "ok"
  end

  private
    # Send an SMS back to the Subscriber
    def respond(message)
      response = Twilio::TwiML::Response.new do |r|
        r.Message message
      end
      render text: response.text
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reservation_params
      params.require(:reservation).permit(:name, :guest_phone, :message)
    end

end
