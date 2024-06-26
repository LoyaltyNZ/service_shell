# Prerequisites

  ruby   File.read('.ruby-version').chomp
  source 'https://rubygems.org'

# Fundamental architecture

  # For queue-based operation with Alchemy Flux, add this
  # BETWEEN the Rack and Hoodoo lines:
  #
  #   gem 'alchemy-flux', '~> 1.3'

  gem 'rack',         '~> 3.1'
  gem 'hoodoo',       '~> 4.0'

# ActiveRecord and PostgreSQL

  gem 'activerecord',  '~> 7.1', :require => 'active_record'
  gem 'activesupport', '~> 7.1', :require => 'active_support'
  gem 'pg',            '~> 1.0'

# Instrumentation

  # Uncomment / remove as required.
  #
  # - https://github.com/DataDog/dd-trace-rb
  # - https://github.com/airbrake/airbrake-ruby
  # - https://github.com/MindscapeHQ/raygun4ruby
  #
  gem 'ddtrace',      '~> 1.20'

# Maintenance

  gem 'rake',         '~> 12.3'

  # For documentation generation via 'rake rdoc' and 'rake rerdoc'.
  #
  # https://github.com/pond/sdoc - which is a fork of the original:
  # https://github.com/zzak/sdoc
  #
  gem 'sdoc', :git => 'https://github.com/pond/sdoc.git', :branch => 'master'

  # Service shell, similar to Rails console, but for any Rack application;
  # likewise a database console, similar to Rails dbconsole.
  #
  # https://github.com/sickill/racksh
  # https://github.com/pond/rackdb
  #
  gem 'racksh',       '~> 1.0'

  gem 'bigdecimal',   '~> 3'
  gem 'drb',          '~> 2'
  gem 'mutex_m',      '~> 0.2'
  gem 'observer',     '~> 0.1'

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

    # Checks for vulnerabilities in bundled Gems (see also ".travis.yml").
    #
    gem 'bundler-audit'

    # Behaviour Driven Development for Ruby.
    #
    gem 'rspec',            '~> 3.13'

    # Rack::Test is a small, simple testing API for Rack apps.
    #
    gem 'rack-test',        '~> 2.1'

    # factory_bot provides a framework and DSL for defining and using
    # factories.
    #
    gem 'factory_bot',      '~> 4.10'

    # Strategies for cleaning databases. Can be used to ensure a clean state
    # for testing.
    #
    gem 'database_cleaner', '~> 2.0'

    # Faker, a port of Data::Faker from Perl, is used to easily generate fake
    # data: names, addresses, phone numbers, etc.
    #
    gem 'faker',            '~> 3.3'

    # Code coverage reports, generated in the 'coverage' folder when tests run.
    #
    gem 'simplecov-rcov',   '~> 0.2'

    # A gem which lets you 'freeze' or change the concept of "now" for tests.
    #
    gem 'timecop',          '~> 0.9'

  end
