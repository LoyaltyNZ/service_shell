# Adapted from:
#
#   https://github.com/cutalion/grape-api-example/blob/master/environment.rb
#
# ...with lots of customisation and explanation.

# Add the directory that "this" Ruby script is sitting in, to the front
# of the array of Ruby 'require' paths.

$LOAD_PATH.unshift( File.dirname( __FILE__ ) )

# Get the Rack environment into 'env' as a symbol.

env = ( ENV[ 'RACK_ENV' ] || 'development' ).to_sym

# Auto-require all gems in the default Gemfile group, along with anything
# specific to the environment.

require 'bundler'
Bundler.require( :default, env )

# Set up an "Service" module that supports configuration parameters via
# ActiveSupport. This provides a convenient point for configuration data
# global across the service - just look in "Service.config". Store the
# filesystem root directory location of the service files in key :root and
# the current environment in :env for convenience.

module Service
  include ActiveSupport::Configurable
end

Service.configure do | config |
  config.root = File.dirname( __FILE__ )
  config.env  = Hoodoo::Services::Middleware.environment()
end

Hoodoo::Services::Middleware.set_log_folder( File.join( Service.config.root, 'log' ) )

# Wake up ActiveRecord using config/database.yml and a default UTC timezone.

require 'yaml'
require 'erb'
require 'active_support/core_ext/hash/indifferent_access'

Service.config.database_config = if ENV[ 'DATABASE_URL' ]
  ENV[ 'DATABASE_URL' ]
else
  path           = File.join( Service.config.root, 'config', 'database.yml' )
  erb_yaml_file  = File.read( path )
  pure_yaml_file = ERB.new( erb_yaml_file ).result
  parsed_file    = HashWithIndifferentAccess[YAML.safe_load( pure_yaml_file, aliases: true )]

  if parsed_file.has_key?( Service.config.env )
    parsed_file[ Service.config.env ]
  else
    raise "Cannot find configuration for environment #{ Service.config.env.inspect }"
  end
end

ActiveRecord.default_timezone = :utc
ActiveRecord::Base.establish_connection( Service.config.database_config )

# Load a config/environments/<foo>.rb file (if it exists) to do any further
# environment-specific work.

specific_environment = "config/environments/#{ Service.config.env }.rb"
require specific_environment if File.exist?( specific_environment )

# Support the useful Rails-ism of a "config/initializers" folder with an
# alphabetical-order-executed set of setup files.

Dir[ 'config/initializers/**/*.rb'     ].sort.each { | f | require f }

# Load model, resource, implementation and interface classes, then load
# any monkey patches that might be present.

Dir[ 'service/models/**/*.rb'          ].sort.each { | f | require f }
Dir[ 'service/resources/**/*.rb'       ].sort.each { | f | require f }
Dir[ 'service/implementations/**/*.rb' ].sort.each { | f | require f }
Dir[ 'service/interfaces/**/*.rb'      ].sort.each { | f | require f }
Dir[ 'service/monkeys/**/*.rb'         ].sort.each { | f | require f }
