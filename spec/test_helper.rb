require 'rails_helper'
require 'vcr'

VCR.configure do |configure|
  configure.cassette_library_dir = "test/vcr_cassettes"
  configure.hook_into :webmock
  configure.filter_sensitive_data("<TWILIO ACCOUNT SID>") { ENV["TWILIO_ACCOUNT_SID"] }
  configure.filter_sensitive_data("<TWILIO AUTH TOKEN>") { ENV["TWILIO_AUTH_TOKEN"] }
  configure.filter_sensitive_data("<TWILIO NUMBER>") { ENV["TWILIO_NUMBER"] }
  configure.filter_sensitive_data("<APPLICATION SID>") { ENV["ANONYMOUS_APPLICATION_SID"] }
end

module Params
  # # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...

  def user_params(params={})
    {
      password: "hello55",
      email: "jard@example.com",
      name: "Jard",
      phone_number: "6195559090",
      country_code: "+1"
    }.merge(params)
  end

  def reservation_params()
    {
      name: "reservation1",
      guest_phone: "6195559090",
      message: "message1",
      property_id: 1,
    }
  end
end

RSpec.configure do |c|
  c.include Params
end
