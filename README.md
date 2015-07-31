# Airtng App: Part 2 - Anonymous Calling and SMS with Twilio

Protect your customers' privacy, and create a seamless interaction by provisioning Twilio numbers on the fly, and routing all voice calls, and messages through your very own 3rd party. This allows you to control the interaction between your customers, while putting your customer's privacy first.

## Setup a Twilio application
Before you can run this app you need to go into your account portal and [create a new Twilio Application](https://www.twilio.com/user/account/apps). Once you have created an app the urls should look like:

**Voice**: http://[your server].com/reservations/connect_voice
**SMS & MMS**: http://[your server].com/reservations/connect_sms

## Running the application

Clone this repository and cd into the directory then.

```
$ bundle install
$ rake db:create db:migrate
$ export TWILIO_ACCOUNT_SID=your account sid
$ export TWILIO_AUTH_TOKEN=your auth token
$ export TWILIO_NUMBER=+16515559999
$ export ANONYMOUS_APPLICATION_SID=your application sid
$ rake test
$ rails server
```

Then visit the application at http://localhost:3000/

## Deploy to Heroku

Hit the button!

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)
