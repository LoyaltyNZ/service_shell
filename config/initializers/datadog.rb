# To enable Datadog support, uncomment the code below and make any changes to
# configure to reflect the location of your Datadog agent.

# # For more information see:
# #
# # * http://gems.datadoghq.com/trace/docs/
# # * https://github.com/DataDog/docker-dd-agent
# #
# require 'ddtrace'
#
# Datadog.configure do | c |
#
#   # Datadog tracing is only enabled in non-test/non-development environments.
#   #
#   c.tracer enabled:  [ 'test', 'development' ].exclude?( ENV[ 'RACK_ENV' ] ),
#            hostname: ENV[ 'DD_AGENT_PORT_8126_TCP_ADDR' ],
#            port:     ENV[ 'DD_AGENT_PORT_8126_TCP_PORT' ]
#
#   c.use :rack, distributed_tracing: true,
#                service_name:        'service_shell'
#
#   # Examples below are optional. If you use Net/HTTP to call out to external
#   # services, or for inter-resource calls on a non-AMQP deployment, keep the
#   # ":http" middleware; likewise ":active_record" if you use that for
#   # persistent storage. The ":dalli" middleware is for Memcached, typically
#   # used as a session store. These and other integrations are described at:
#   #
#   #   http://gems.datadoghq.com/trace/docs/#Available_Integrations
#   #
#   c.use :http, distributed_tracing: true
#   c.use :active_record
#   c.use :dalli
#
# end
