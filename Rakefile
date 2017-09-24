#!/usr/bin/env rake
#
# Adapted from:
#   http://stackoverflow.com/questions/19206764/how-can-i-load-activerecord-database-tasks-on-a-ruby-project-outside-rails
#   https://gist.github.com/drogus/6087979

require 'bundler/setup'
require 'yaml'
require 'erb'
require 'active_record'
require 'active_support/core_ext/hash/indifferent_access'
require 'rdoc/task'

include ActiveRecord::Tasks

class Seeder
  def initialize( seed_file )
    @seed_file = seed_file
  end

  def load_seed
    raise "Seed file '#{ @seed_file }' does not exist" unless File.file?( @seed_file )
    load @seed_file
  end
end

# You MUST specify "env" as a Symbol and the configuration that ends up
# in "database_configuration" MUST be a HashWithIndifferentAccess, else
# some of the "db:..." tasks will fail in strange ways, which includes
# (depending on the task) potentially executing in the wrong environment
# (!), typically "test" when you specified something else with RACK_ENV.

DatabaseTasks.root             = root = File.expand_path( '..', __FILE__ )
DatabaseTasks.env              = ( ENV[ 'RACK_ENV' ] || 'development' ).to_sym
DatabaseTasks.db_dir           = File.join( root, 'db' )
DatabaseTasks.fixtures_path    = File.join( root, 'test', 'fixtures' )
DatabaseTasks.migrations_paths = [ File.join( root, 'db', 'migrate' ) ]
DatabaseTasks.seed_loader      = Seeder.new( File.join( root, 'db', 'seeds.rb' ) )

DatabaseTasks.database_configuration = begin
  path           = File.join( DatabaseTasks.root, 'config', 'database.yml' )
  erb_yaml_file  = File.read( path )
  pure_yaml_file = ERB.new( erb_yaml_file ).result
  parsed_file    = HashWithIndifferentAccess[ YAML.load( pure_yaml_file ) ]

  if parsed_file[ DatabaseTasks.env ].blank?
    raise "Cannot find configuration for environment #{ DatabaseTasks.env.inspect }"
  end

  parsed_file
end

task :environment do
  if ENV[ 'DATABASE_URL' ]
    ActiveRecord::Base.establish_connection( ENV[ 'DATABASE_URL' ] )
  else
    ActiveRecord::Base.configurations = DatabaseTasks.database_configuration
    ActiveRecord::Base.establish_connection( DatabaseTasks.env )
  end
end

load 'active_record/railties/databases.rake'

namespace :g do
  desc 'Generate migration. Specify name in the NAME variable'

  task :migration => :environment do
    require 'active_support/core_ext/string/strip'

    name            = ENV[ 'NAME' ] || raise( 'Specify name: rake g:migration NAME=create_users' )
    timestamp       = Time.now.strftime( '%Y%m%d%H%M%S' )
    path            = File.expand_path( "../db/migrate/#{timestamp}_#{name}.rb", __FILE__ )
    migration_class = name.split( '_' ).map( &:capitalize ).join()

    File.open( path, 'w' ) do | file |
      file.write <<-EOF.strip_heredoc
        class #{migration_class} < ActiveRecord::Migration
          def up
          end

          def down
          end
        end
      EOF
    end

    puts 'Done'
    puts path
  end
end

Rake::RDocTask.new do | rd |
 require 'sdoc'

 rd.rdoc_files.include( 'README.md', 'service/**/*.rb', 'lib/**/*.rb' )
 rd.rdoc_dir = 'docs/rdoc'
 rd.title = 'Platform Service: Generic'
 rd.main = 'README.md'
 rd.generator = 'sdoc'
end
