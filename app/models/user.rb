class User < ActiveRecord::Base
  has_secure_password

  validates :email,  presence: true, format: { with: /\A.+@.+$\Z/ }, uniqueness: true
  validates :name, presence: true
  validates :country_code, presence: true
  validates :phone_number, presence: true, uniqueness: true
  validates_length_of :password, in: 6..20, on: :create

  has_many :vacation_properties
  has_many :reservations, through: :vacation_properties

  after_create :save_join_phone_number!

  def send_message_via_sms(message, from_number = ENV['TWILIO_NUMBER'])
    @client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
    @client.messages.create(
      from: from_number,
      to: "#{self.phone_number}",
      body: message,
    )
  end

  def check_for_reservations_pending
    if pending_reservation
      pending_reservation.notify_host(true)
    end
  end

  def pending_reservation
    self.reservations.pending.first
  end

  def pending_reservations
    self.reservations.pending
  end

  private

  # No reason to save phone number without the area_code or country_code, it's what twilio & ActiveRecord expect
  def save_join_phone_number!
    self.update!(phone_number: "#{self.country_code}#{self.area_code}#{self.phone_number}")
  end

end
