# To enable Airbrake support, fill in the Airbrake project ID and key for
# the Airbrake project of your choice and uncomment the code below.

# unless Service.config.env.test? || Service.config.env.development?
#
#   require 'airbrake'
#
#   Airbrake.configure do | config |
#     config.project_id  = 'YOUR_AIRBRAKE_PROJECT_ID'
#     config.project_key = 'YOUR_AIRBRAKE_PROJECT_KEY'
#   end
#
#   Hoodoo::Services::Middleware::ExceptionReporting.add(
#     Hoodoo::Services::Middleware::ExceptionReporting::AirbrakeReporter
#   )
#
# end
