class User < ActiveRecord::Base
  has_secure_password
  
  validates :email,  presence: true, format: { with: /\A.+@.+$\Z/ }, uniqueness: true
  validates :name, presence: true
  validates :country_code, presence: true
  validates :phone_number, presence: true, uniqueness: true
  validates_length_of :password, :in => 6..20, :on => :create

  has_many :vacation_properties
  has_many :reservations, through: :vacation_properties

  after_create :register_with_authy

  def send_message_via_sms(message)
    @app_number = ENV['TWILIO_NUMBER']
    @client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    sms_message = @client.account.messages.create(
      :from => @app_number,
      :to => self.phone_number,
      :body => message,
    )
    puts sms_message.to
  end

  def check_for_reservations_pending
    if pending_reservation
      pending_reservation.notify_host(true)
    end
  end

  def pending_reservation
    self.reservations.where(status: "pending").first
  end

  def pending_reservations
    self.reservations.where(status: "pending")
  end


  def verify_auth_token(postedToken)
    # Use Authy to send the verification token
    token = Authy::API.verify(id: self.authy_id, token: postedToken)

    if token.ok?
      self.update(verified: true)
      self.send_message_via_sms("You did it! Signup complete :)")
      return true
    else
      errors.add(:verified, "Incorrect code, please try again")
      return false
    end
  end

  private
    def register_with_authy
      # Create user on Authy, will return an id on the object
      authy = Authy::API.register_user(
        email: self.email,
        cellphone: self.phone_number,
        country_code: self.country_code
      )
      self.update(authy_id: authy.id)

      self.send_authy_token_via_sms
    end

    def send_authy_token_via_sms
      Authy::API.request_sms(id: self.authy_id)
    end
end
