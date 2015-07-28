class Reservation < ActiveRecord::Base
  validates :name, presence: true
  validates :guest_phone, presence: true

  enum status: [ :pending, :confirmed, :rejected ]

  belongs_to :vacation_property
  belongs_to :user

  after_create :provision_phone_number

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
    self.status = "confirmed"
    self.save!
  end

  def reject!
    self.status = "rejected"
    self.save!
  end

  def notify_guest
    if self.status_changed? && (self.status == "confirmed" || self.status == "rejected")
      message = "Your recent request to stay at #{self.vacation_property.description} was #{self.status}."
      self.guest.send_message_via_sms(message)
    end
  end

  private

  def provision_phone_number
    @client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    begin
      @numbers = @client.account.available_phone_numbers.get('US').local.list(:area_code => self.host.area_code)
      if not @numbers.any?
        @numbers = @client.account.available_phone_numbers.get('US').local.list()
      end
      # Purchase the number
      @number = @numbers[0].phone_number
      @client.account.incoming_phone_numbers.create(:phone_number => @number)

      # Set the reservation.phone_number
      self.phone_number = @number
      self.save!
      
    rescue Exception => e
      puts e.message
    end
  end
end
