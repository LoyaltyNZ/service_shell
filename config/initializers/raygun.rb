# To enable Raygun support, fill in the Raygun API key and uncomment
# the code below.

# require 'raygun4ruby'
#
# Raygun.setup do | config |
#   config.api_key = 'YOUR_RAYGUN_API_KEY'
# end
#
# Hoodoo::Services::Middleware::ExceptionReporting.add(
#   Hoodoo::Services::Middleware::ExceptionReporting::RaygunReporter
# ) unless Service.config.env.test? || Service.config.env.development?
