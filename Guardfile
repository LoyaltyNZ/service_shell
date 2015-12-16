########################################################################
# File::    Guardfile
# (C)::     Loyalty New Zealand 2014
#
# Purpose:: For use with Guard; see:
#
#           * https://github.com/guard/guard/
#           * https://github.com/rchampourlier/guard-shotgun
#           * https://github.com/guard/guard-rspec
#
# ----------------------------------------------------------------------
#           23-Dec-2014 (ADH): Created.
########################################################################

require 'hoodoo'

# All service source files alteration of which cause the service to be
# restarted during local development and all tests to run.

all_service_source_files = [
  'config.ru',
  'environment.rb',
  'service.rb',

  %r{^(config|lib|service)/.*\.rb}
]

# Tell guard-shotgun about the files above.

options = {
  :port => ENV[ 'PORT' ] || Hoodoo::Utilities.spare_port().to_s
}

options[ :server ] = :alchemy unless ENV[ 'AMQ_ENDPOINT' ].nil?

guard( 'shotgun', options ) do
  all_service_source_files.each do | info |
    watch( info )
  end
end

# # Enable the block of code below if you want RSpec tests running under Guard
# # too. By default, tests are run manually.
#
# # Tell guard-rspec about the files above along with listing items in the
# # spec folder itself.
#
# guard( 'rspec', :cmd => 'bundle exec rspec' ) do
#
#   all_suite_source_files = all_service_source_files + [
#     %r{^(spec/support|spec/factories)/.*\.rb},
#     %r{spec/[^/]+\.rb}
#   ]
#
#   all_suite_source_files.each do | info |
#     watch( info ) { 'spec' }
#   end
#
#   watch( %r{^spec/.+_spec\.rb} )
#
# end
