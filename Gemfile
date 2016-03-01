# Prerequisites

  ruby   '2.2.4'
  source 'https://rubygems.org'

# Fundamental architecture

  # For queue-based operation with Alchemy Flux, add this
  # BETWEEN the Rack and Hoodoo lines:
  #
  #   gem 'alchemy-flux', '~> 0.1'

  gem 'rack',   '~> 1.5'
  gem 'hoodoo', '~> 1.1'

# ActiveRecord and PostgreSQL

  gem 'activerecord',  '~> 4.1', :require => 'active_record'
  gem 'activesupport', '~> 4.1', :require => 'active_support'
  gem 'pg',            '~> 0.17'

# Instrumentation

  gem 'newrelic_rpm', '~> 3.9'
  gem 'airbrake',     '~> 4.1'
  gem 'raygun4ruby',  '~> 1.1'

# Maintenance

  gem 'rake', '~> 10.3'

  # Service shell, similar to Rails console, but for any Rack application/
  #
  # https://github.com/sickill/racksh
  #
  gem 'racksh', '~> 1.0'

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

    # used for the migration generators
    gem 'thor'

  end

  group :test do

    # Behaviour Driven Development for Ruby.
    #
    gem 'rspec',            '~> 3.1'

    # Rack::Test is a small, simple testing API for Rack apps.
    #
    gem 'rack-test',        '~> 0.6'

    # factory_girl provides a framework and DSL for defining and using
    # factories.
    #
    gem 'factory_girl',     '~> 4.4'

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

    # making it dead simple to test time-dependent code
    #
    gem 'timecop'
  end
