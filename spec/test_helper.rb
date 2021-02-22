require 'rails_helper'
require 'vcr'

VCR.configure do |configure|
  configure.cassette_library_dir = "spec/vcr_cassettes"
  configure.hook_into :webmock
  configure.register_request_matcher :uri_regex do |request1, request2|
    request1.uri.match(request2.uri)
  end
end

module Params
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
