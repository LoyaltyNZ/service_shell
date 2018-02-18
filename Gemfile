# Prerequisites

  ruby   '2.3.6'
  source 'https://rubygems.org'

# Fundamental architecture

  # For queue-based operation with Alchemy Flux, add this
  # BETWEEN the Rack and Hoodoo lines:
  #
  #   gem 'alchemy-flux', '~> 1.2'

  gem 'rack',         '~> 2.0'
  gem 'hoodoo',       '~> 2.2'

# ActiveRecord and PostgreSQL

  gem 'activerecord',  '~> 5.1', :require => 'active_record'
  gem 'activesupport', '~> 5.1', :require => 'active_support'
  gem 'pg',            '~> 0.21'

# Instrumentation

  # Uncomment / remove as required.
  #
  # - https://github.com/newrelic/rpm
  # - https://github.com/DataDog/dd-trace-rb
  # - https://github.com/airbrake/airbrake-ruby
  # - https://github.com/MindscapeHQ/raygun4ruby
  #
  # gem 'newrelic_rpm', '~> 4.3'
  # gem 'ddtrace',      '~> 0.11'
  # gem 'airbrake',     '~> 7.1'
  # gem 'raygun4ruby',  '~> 2.6'

# Workarounds

  # FFI 1.9.21 is harmful. At the time of writing it appears to be fixed,
  # but for some reason a 1.9.22 release has not been made.
  #
  # TODO: Remove me once FFI is fixed.
  #
  # - https://github.com/ffi/ffi/issues/607
  # - https://github.com/ffi/ffi/issues/608
  #
  gem 'ffi', '1.9.18'

# Maintenance

  gem 'rake', '~> 12.2'

  # Service shell, similar to Rails console, but for any Rack application;
  # likewise a database console, similar to Rails dbconsole.
  #
  # https://github.com/sickill/racksh
  # https://github.com/pond/rackdb
  #
  gem 'racksh', '~> 1.0'
  gem 'rackdb', '~> 2.0'

# Development and test support

  group :development do

    # Reload your service when important files change.
    #
    # https://github.com/rchampourlier/guard-shotgun
    #
    gem 'guard-shotgun', :require => false

    # Guard::RSpec automatically & intelligently launches specs when files
    # are modified.
    #
    # https://github.com/guard/guard-rspec
    #
    gem 'guard-rspec', :require => false

    # For documentation generation via 'rake rdoc' and 'rake rerdoc'.
    #
    # https://github.com/pond/sdoc - which is a fork of the original:
    # https://github.com/voloko/sdoc
    #
    gem 'sdoc', :git => 'https://github.com/pond/sdoc.git', :branch => 'master'

  end

  group :development, :test do

    # Ruby command 'byebug' will launch a debugging session in the Rack
    # shell - the Ruby >= 2 equivalent of 'debug'.
    #
    # https://github.com/deivid-rodriguez/byebug
    # https://github.com/deivid-rodriguez/pry-byebug
    #
    gem 'byebug'
    gem 'pry-byebug'

    # Used for the migration generators.
    #
    # https://github.com/erikhuda/thor
    #
    gem 'thor'

  end

  group :test do

    # Behaviour Driven Development for Ruby.
    #
    gem 'rspec',            '~> 3.1'

    # Rack::Test is a small, simple testing API for Rack apps.
    #
    gem 'rack-test',        '~> 0.6'

    # factory_bot provides a framework and DSL for defining and using
    # factories.
    #
    gem 'factory_bot',      '~> 4.8'

    # Strategies for cleaning databases. Can be used to ensure a clean state
    # for testing.
    #
    gem 'database_cleaner', '~> 1.3'

    # Faker, a port of Data::Faker from Perl, is used to easily generate fake
    # data: names, addresses, phone numbers, etc.
    #
    gem 'faker',            '~> 1.4'

    # Code coverage reports, generated in the 'coverage' folder when tests run.
    #
    gem 'simplecov-rcov',   '~> 0.2'

  end
