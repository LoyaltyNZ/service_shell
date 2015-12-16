# Load all FactoryGirl models and enable the FactoryGirl DSL during testing.

Dir[ "#{ File.dirname( __FILE__ ) }/../factories/*.rb" ].each { | f | require f }

RSpec.configure do | config |
  config.include FactoryGirl::Syntax::Methods
end
