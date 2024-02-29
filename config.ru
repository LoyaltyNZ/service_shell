# Load the 'environment.rb' file.
#
require File.expand_path( '../environment', __FILE__ )

# Recommended for Datadog tracing.
#
# https://www.datadoghq.com
# https://github.com/DataDog/dd-trace-rb
#
if defined?( Datadog )

  use Datadog::Tracing::Contrib::Rack::TraceMiddleware

end

# Tell Rack about the middleware.
#
use( Hoodoo::Services::Middleware )

# Run the service.
#
require File.expand_path( '../service', __FILE__ )
run( ServiceApplication.new )
