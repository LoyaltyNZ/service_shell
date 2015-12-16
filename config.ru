# Load the 'environment.rb' file.

require File.expand_path( '../environment', __FILE__ )

# Recommended for New Relic automatic Rack monitoring.
#
# https://docs.newrelic.com/docs/agents/ruby-agent/frameworks/rack-middlewares

if defined?( NewRelic )

  require 'new_relic/rack/agent_hooks'
  require 'new_relic/rack/browser_monitoring'

  use( NewRelic::Rack::AgentHooks )
  use( NewRelic::Rack::BrowserMonitoring )

end

# Tell Rack about the middleware.

use( Hoodoo::Services::Middleware )

# Run the service.

require File.expand_path( '../service', __FILE__ )
run( ServiceApplication.new )
