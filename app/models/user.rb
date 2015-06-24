class User < ActiveRecord::Base
  has_secure_password

  has_many :vacation_properties

  after_create :register_with_authy

  validates :email,  presence: true, format: { with: /\A.+@.+$\Z/ }, uniqueness: true
  validates :name, presence: true
  validates :country_code, presence: true
  validates :phone_number, presence: true

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

  def send_message_via_sms(message)
    @client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    message = @client.account.messages.create(
      :from => ENV['TWILIO_NUMBER'],
      :to => self.country_code+self.phone_number,
      :body => message
    )
    puts message.to
  end

  def send_authy_token_via_sms
    Authy::API.request_sms(id: self.authy_id)
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
end
