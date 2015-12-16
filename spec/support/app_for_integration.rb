# Integration tests in 'spec/integration' run 'rack-test' DSL methods like
# 'get' or 'post'. These expect to call a method 'app' to get hold of the
# Rack application under test. This RSpec DSL extension provides the 'app'
# method.
#
module RSpecDefineAppCallForIntegration
  def app
    eval(
      "Rack::Builder.new { def run_without_newrelic(a); run (a); end; ( " <<
      File.read( "#{ File.dirname( __FILE__ ) }/../../config.ru" ) <<
      "\n ) }"
    )
  end
end

RSpec.configure do | config |
  config.include( RSpecDefineAppCallForIntegration )
end
