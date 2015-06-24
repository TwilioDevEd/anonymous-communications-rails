Authy.api_key = Rails.application.secrets.authy_key
Authy.api_uri = 'https://api.authy.com/'

puts Authy.api_key
