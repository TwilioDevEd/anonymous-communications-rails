class ReservationsController < ApplicationController

  # GET /vacation_properties/new
  def new
    @reservation = Reservation.new
  end

  def create
    @vacation_property = VacationProperty.find(params[:reservation][:property_id])
    @reservation = @vacation_property.reservations.create(reservation_params)

    if @reservation.save
      flash[:notice] = "Sending your reservation request now."
      redirect_to @vacation_property
    else
      flast[:danger] = @reservation.errors
    end
  end

  # webhook for twilio incoming message from host
  def accept_or_reject
    incoming = Sanitize.clean(params[:From]).gsub(/^\+\d/, '')
    response = params[:Body].downcase

    @host = User.find_by(phone_number: incoming)
    @reservation = @host.pending_reservation

    if response == "accept" || response == "yes"
      @reservation.confirm
    else
      @reservation.reject
    end

    @host.check_for_reservations_pending

    render text: "Reservation updated"
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def reservation_params
      params.require(:reservation).permit(:name, :phone_number, :message)
    end

end
