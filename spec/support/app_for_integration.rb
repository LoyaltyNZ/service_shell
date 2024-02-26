# frozen_string_literal: true

# Integration tests in 'spec/integration' run 'rack-test' DSL methods like
# 'get' or 'post'. These expect to call a method 'app' to get hold of the
# Rack application under test. This RSpec DSL extension provides the 'app'
# method.
#
module RSpecDefineAppCallForIntegration
  def app = Rack::Builder.parse_file('config.ru')
end

RSpec.configure do | config |
  config.include( RSpecDefineAppCallForIntegration )
end
