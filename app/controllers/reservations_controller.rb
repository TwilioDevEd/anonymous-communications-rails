class ReservationsController < ApplicationController

  # GET /vacation_properties/new
  def new
    @reservation = Reservation.new
  end

  def create
    puts "params #{params}"
    @vacation_property = VacationProperty.find(params[:reservation][:property_id])
    @reservation = @vacation_property.reservations.create(reservation_params)

    respond_to do |format|
      if @reservation.save
        format.html { redirect_to @vacation_property, notice: 'Vacation property was successfully created.' }
        format.json { render :show, status: :created, location: @vacation_property }
      else
        format.html { render :new }
        format.json { render json: @vacation_property.errors, status: :unprocessable_entity }
      end
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
    # Use callbacks to share common setup or constraints between actions.
    def set_vacation_property
      @vacation_property = VacationProperty.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reservation_params
      params.require(:reservation).permit(:name, :phone_number, :message)
    end
end
