require 'fileutils'
require 'spec_helper.rb'

# The main Generators::EffectiveDate test set has to mock some of the
# migration path generation methods to work predictably and reliably,
# but this means there's no test coverage for the mocked code. Here,
# we explicitly unit test those parts.
#
# These tests are not exhaustive - they just cover the gaps left after
# the Generators::EffectiveDate tests have run.
#
RSpec.describe Generators::Utils do

  # This should just find the "db/migrate" folder locally, using
  # whatever 'File.join' semantics are appropriate.
  #
  context '#root_migration_dir' do
    it 'finds the root folder' do
      result = Generators::Utils.root_migration_dir()
      expect( result ).to eq( File.join( 'db', 'migrate' ) )
    end
  end

  # This expects a folder full of time-based migration names with a
  # to-second resolution that may mean several rapidly-generate
  # migrations have a colliding time-based part of their name. The
  # method is supposed to extract the highest time and, if it would
  # otherwise collide, add one to it.
  #
  # The test generates a bunch of so-named files with time-based
  # names some time in the future, so that when the main test runs
  # it finds 'now' is too "low" and increments accordingly. We can
  # thus predict exactly what the time-based part of the filename
  # returned by the method under test should be.
  #
  context '#next_migration_number' do
    before :each do
      @paths = []
      @start = Time.now.strftime( '%Y%m%d%H%M%S' ).to_i
      @max   = 100

      ( @max - 4 ).upto( @max ) do | i |
        path = File.join(
          Generators::Utils.root_migration_dir(),
          "#{ @start + i }_empty_test_file.rb"
        )

        FileUtils.touch( path )
        @paths << path
      end
    end

    after :each do
      @paths.each do | path |
        FileUtils.rm( path )
      end
    end

    it 'generates the next number' do
      result = Generators::Utils.next_migration_number()
      expect( result ).to eq( ( @start + @max + 1 ).to_s )
    end
  end
end
