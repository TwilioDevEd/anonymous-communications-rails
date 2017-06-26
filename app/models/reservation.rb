class Reservation < ActiveRecord::Base
  validates :name, presence: true
  validates :guest_phone, presence: true

  enum status: [ :pending, :confirmed, :rejected ]

  belongs_to :vacation_property
  belongs_to :user

  def notify_host(force = false)
    # Don't send the message if we have more than one and we aren't being forced
    if self.host.pending_reservations.length > 1 and !force
      return
    else
      message = "You have a new reservation request from #{self.name} for #{self.vacation_property.description}:

      '#{self.message}'

      Reply [accept] or [reject]."

      self.host.send_message_via_sms(message)
    end
  end

  def host
    @host = User.find(self.vacation_property[:user_id])
  end

  def guest
    @guest = User.find_by(phone_number: self.guest_phone)
  end

  def confirm!
    provision_phone_number
    self.update!(status: "confirmed")
  end

  def reject!
    self.update!(status: "rejected")
  end

  def notify_guest
    if self.status_changed? && (self.status == "confirmed" || self.status == "rejected")
      message = "Your recent request to stay at #{self.vacation_property.description} was #{self.status}."
      self.guest.send_message_via_sms(message)
    end
  end

  def send_message_to_guest(message)
    message = "From #{self.host.name}: #{message}"
    self.guest.send_message_via_sms(message, self.phone_number)
  end

  def send_message_to_host(message)
    message = "From guest #{self.guest.name}: #{message}"
    self.host.send_message_via_sms(message, self.phone_number)
  end

  private

  def provision_phone_number
    @client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    begin
      # Lookup numbers in host area code, if none than lookup from anywhere
      @numbers = @client.available_phone_numbers.get('US').local.list(:area_code => self.host.area_code)
      if @numbers.empty?
        @numbers = @client.available_phone_numbers.get('US').local.list()
      end

      # Purchase the number & set the application_sid for voice and sms, will
      # tell the number where to route calls/sms
      @number = @numbers.first.phone_number
      @anon_number = @client.incoming_phone_numbers.create(
        :phone_number => @number,
        :voice_application_sid => ENV['ANONYMOUS_APPLICATION_SID'], 
        :sms_application_sid => ENV['ANONYMOUS_APPLICATION_SID']
      )

      # Set the reservation.phone_number
      self.update!(phone_number: @number)

    rescue Exception => e
      puts "ERROR: #{e.message}"
    end
  end
end
