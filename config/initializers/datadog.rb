# To enable DataDog support, uncomment the code below and make sure you
# run your service with all required DataDog environment variables set;
# see "config/datadog.yml" for details.

# require 'ddtrace/contrib/rack/middlewares'
#
# Datadog::Monkey.patch_module(:active_record)
#
# tracer = Datadog.tracer
# tracer.configure(
#     enabled: ['test','development'].exclude?(ENV['RACK_ENV']),
#     hostname: ENV['DD_AGENT_PORT_8126_TCP_ADDR'],
#     port: ENV['DD_AGENT_PORT_8126_TCP_PORT']
# )
# Service.config.com_datadoghq_datadog_tracer = tracer