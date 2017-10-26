# Load all FactoryBot models and enable the FactoryBot DSL during testing.

Dir[ "#{ File.dirname( __FILE__ ) }/../factories/*.rb" ].each { | f | require f }

RSpec.configure do | config |
  config.include FactoryBot::Syntax::Methods
end
