# To enable Datadog support, uncomment the code below and make any changes to
# configure to reflect the location of your Datadog agent.
# This is the default setup suggested in: https://github.com/DataDog/docker-dd-agent

# require 'ddtrace/contrib/rack/middlewares'
#
# Datadog::Monkey.patch_module( :active_record )
#
# tracer = Datadog.tracer
#
# tracer.configure(
#   :enabled   => [ 'test','development' ].exclude?( ENV[ 'RACK_ENV' ] ),
#   :hostname  => ENV[ 'DD_AGENT_PORT_8126_TCP_ADDR' ],
#   :port:     => ENV[ 'DD_AGENT_PORT_8126_TCP_PORT' ]
# )
#
# Service.config.com_datadoghq_datadog_tracer = tracer
