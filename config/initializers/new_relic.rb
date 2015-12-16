# To enable New Relic support, uncomment the code below and make sure you
# run your service with all required New Relic environment variables set;
# see "config/newrelic.yml" for details. The two most important items
# are NEW_RELIC_LICENSE_KEY and NEW_RELIC_APP_NAME.

# NewRelic::Agent.manual_start
#
# # Try and enable GC stats.
# #
# # https://docs.newrelic.com/docs/agents/ruby-agent/features/garbage-collection
#
# begin
#   GC::Profiler.enable
# rescue
# end
#
# begin
#   GC.enable_stats
# rescue
# end
