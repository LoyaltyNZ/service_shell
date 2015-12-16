# To enable Airbrake support, fill in the Airbrake API key for the Airbrake
# project of your choice and uncomment the code below.

# require 'airbrake'
#
# Airbrake.configure do | config |
#   config.api_key = 'YOUR_AIRBRAKE_API_KEY'
# end
#
# Hoodoo::Services::Middleware::ExceptionReporting.add(
#   Hoodoo::Services::Middleware::ExceptionReporting::AirbrakeReporter
# ) unless Service.config.env.test? || Service.config.env.development?
