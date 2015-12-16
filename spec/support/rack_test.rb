# Support easy integration testing.
#
require 'rack/test'

RSpec.configure do | config |
  # Provides familiar-ish 'get'/'post' etc. DSL for simulated URL fetch tests.
  config.include Rack::Test::Methods
end
