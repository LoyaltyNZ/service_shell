require 'spec_helper'
require 'active_record'

# When the generators are required, they might be running things like Thor.
# Although we'll test the classes directly here, Thor (for example) requires
# a Ruby script to call "#start" to be a self-contained command line tool;
# when require'd here without being run thus, it'll complain about missing
# command line arguments. So - suppress those.
#
begin
  $old_stderr = $stderr.clone
  $stderr.reopen( File::NULL, 'w' )

  Dir[ 'bin/generators/classes/**/*.rb' ].sort.each { | f | require f }

ensure
  $stderr.reopen( $old_stderr )

end

RSpec.describe Generators::EffectiveDate do

  def destination_root
    File.join( File.dirname( __FILE__ ), 'sandbox' )
  end

  let( :time           ) { Time.parse("2014-10-10T01:16:22Z") }
  let( :now            ) { Time.now.strftime('%Y%m%d%H%M%S') }
  let( :table_name     ) { 'r_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa_es' } #47 char
  let( :model_name     ) { table_name.singularize.camelize }
  let( :model_klass    ) { Object.const_get( model_name ) }
  let( :generator      ) { Generators::EffectiveDate.new( [ table_name, "data", "name" ] ) }
  let( :generator_full ) { Generators::EffectiveDate.new( [ table_name, "data", "updated_at", "name", "created_at" ] ) }
  let( :migrate_up     ) { require file; spec_helper_silence_stdout() { migrator.up } }
  let( :migrate_down   ) { require file; spec_helper_silence_stdout() { migrator.down } }
  let( :file           ) { generate(); File.join( destination_root, filename ) }

  before do
    Timecop.freeze( time )
    allow( Generators::Utils ).to receive( :root_migration_dir    ).and_return( destination_root )
    allow( Generators::Utils ).to receive( :next_migration_number ).and_return( now              )
    ::FileUtils.rm_rf( destination_root )
  end

  after do
    Timecop.return
    ::FileUtils.rm_rf( destination_root )
  end

  context 'when the table name is too long' do
    let( :table_name ) { 'r_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa_es' } #48 char

    it 'raises an error' do
      expect{ generator }.to raise_error(
        Generators::TableNameLengthExceeded,
        "The table name must not exceed #{ Generators::MAX_TABLE_NAME_LENGTH } characters in length"
      )
    end
  end

  shared_examples_for 'valid file' do
    it 'creates a correctly named file' do
      generate()
      file = File.join( destination_root, filename )
      expect( File.exist?( file ) ).to be true
    end
  end

  shared_examples_for 'valid migration running' do
    it 'runs the migration' do
      expect{ migrate_up }.not_to raise_error
      expect{ migrate_down }.not_to raise_error
    end
  end

  describe 'creating history table' do
    let( :filename   ) { "#{now}_create_history_table_for_#{table_name}.rb" }
    let( :table_name ) { 'r_migration_test_tables' }
    let( :migrator   ) { Object.const_get( "CreateHistoryTableFor#{model_name.pluralize}" ).new }
    let( :generate   ) { spec_helper_silence_stdout() { generator.create_history_table_migration } }
    let( :history_model_klass ) { Object.const_get( "#{table_name}_history_entries".singularize.camelize ) }

    before do
      spec_helper_silence_stdout() do
        ActiveRecord::Migration.create_table( table_name ) do | t |
          t.string     :name
          t.text       :data
          t.timestamps :null => false
        end
        Object.const_set( model_name, Class.new( ActiveRecord::Base ) ){} unless Object.const_defined?(model_name)
        model_klass.reset_column_information
      end
    end

    shared_examples_for 'migration which generates expected columns' do
      it 'are generated' do
        expect( ActiveRecord::Base.connection.table_exists? "#{table_name}_history_entries" ).to be false
        migrate_up
        expect( ActiveRecord::Base.connection.table_exists? "#{table_name}_history_entries" ).to be true

        history_model = "#{table_name}_history_entries".singularize.camelize
        Object.const_set( history_model, Class.new( ActiveRecord::Base ) ){} unless Object.const_defined?( history_model )

        history_model_klass.reset_column_information

        column_names = history_model_klass.columns.map{ | x | x.name }
        expect( column_names ).to match_array( [
          'created_at',
          'updated_at',
          'effective_start',
          'effective_end',
          'uuid',
          'id',
          'name',
          'data',
        ] )

        migrate_down
        expect( ActiveRecord::Base.connection.table_exists? "#{table_name}_history_entries" ).to be false
      end
    end

    it_behaves_like 'valid file'

    context 'migration execution' do
      it_behaves_like 'valid migration running'
      it_behaves_like 'migration which generates expected columns'

      context 'when validating the constraints' do
        let( :start_time ) { time }
        let( :end_time ) { start_time + 2.hours }

        let( :first_record ) {
          r = history_model_klass.new
          r.id = '1234_0'
          r.uuid = '1234'
          r.effective_start = start_time
          r.effective_end = end_time
          r
        }

        let( :second_record ) {
          r = history_model_klass.new
          r.id = '1234_1'
          r.uuid = '1234'
          r.effective_start = start_time
          r.effective_end = end_time
          r
        }

        before do
          migrate_up
          history_model = "#{table_name}_history_entries".singularize.camelize
          Object.const_set( history_model, Class.new( ActiveRecord::Base ) ){} unless Object.const_defined?( history_model )

          first_record.save
        end

        context 'with a duplicate id' do
          it 'raises an error' do
            r = second_record
            r.id = '1234_0'
            r.uuid = '9876' #set the uuid to avoid the overlap constraint
            begin
              r.save
              # If save succeeds, the exception was not thrown and the test fails
              expect(true).to be(false)
            rescue => ex
              expect(ex.cause.to_s ).to match( /PG::UniqueViolation/ )
              expect(ex.cause.to_s ).to match( /duplicate key value violates unique constraint/ )
            end
          end
        end

        context 'with a duplicate uuid/start/end' do
          it 'raises an error' do
            begin
              second_record.save
              # If save succeeds, the exception was not thrown and the test fails
              expect(true).to be(false)
            rescue => ex
              expect(ex.cause.to_s).to match(/PG::UniqueViolation/)
              expect(ex.cause.to_s).to match(/ duplicate key value violates unique constraint/)
            end
          end
        end

        context 'validating overlap constraints' do

          context 'with contiguous times' do
            it 'saves the record' do
              r = second_record
              r.effective_start = first_record.effective_end
              r.effective_end = first_record.effective_end + 4.hours

              expect{ r.save }.to change( history_model_klass, :count ).by( 1 )
            end
          end

          context 'with gaps' do
            it 'saves the record' do
              r = second_record
              r.effective_start = first_record.effective_end + 1.hour
              r.effective_end = first_record.effective_end + 4.hours

              expect{ r.save }.to change( history_model_klass, :count ).by( 1 )
            end
          end

          context 'that overlap' do
            context 'for different uuids' do
              it 'saves the record' do
                r = second_record
                r.uuid = 'foo' # set to a different uuid
                r.effective_start = first_record.effective_end - 3.hour
                r.effective_end = first_record.effective_end

                expect{ r.save }.to change( history_model_klass, :count ).by( 1 )
              end
            end
            context 'for the same uuid' do
              context 'when the second start is before the first end' do
                it 'throws an error' do
                  r = second_record
                  r.effective_start = first_record.effective_end - 1.hour
                  r.effective_end = first_record.effective_end + 2.hours
                  begin
                    r.save
                    # If save succeeds, the exception was not thrown and the test fails
                    expect(true).to be(false)
                  rescue => ex
                    expect(ex.cause.to_s).to match(/PG::ExclusionViolation/)
                  end
                end
              end
              context 'when the second start and end is within the first start end' do
                it 'throws an error' do
                  r = second_record
                  r.effective_start = first_record.effective_end - 10.minutes
                  r.effective_end = first_record.effective_end - 2.minutes
                  begin
                    r.save
                    # If save succeeds, the exception was not thrown and the test fails
                    expect(true).to be(false)
                  rescue => ex
                    expect(ex.cause.to_s).to match(/PG::ExclusionViolation/)
                  end
                end
              end
              context 'when the first is within the seconds range' do
                it 'throws an error' do
                  r = second_record
                  r.effective_start = first_record.effective_start - 2.hour
                  r.effective_end = first_record.effective_start + 5.hours
                  begin
                    r.save
                    # If save succeeds, the exception was not thrown and the test fails
                    expect(true).to be(false)
                  rescue => ex
                    expect(ex.cause.to_s).to match(/PG::ExclusionViolation/)
                  end
                end
              end
              context 'when the firsts end is within the seconds range' do
                it 'throws an error' do
                  r = second_record
                  r.effective_start = first_record.effective_end - 1.hour
                  r.effective_end = first_record.effective_end + 2.hours
                  begin
                    r.save
                    # If save succeeds, the exception was not thrown and the test fails
                    expect(true).to be(false)
                  rescue => ex
                    expect(ex.cause.to_s).to match(/PG::ExclusionViolation/)
                  end
                end
              end
            end
          end
        end
      end
    end

    context 'over-specified command line' do
      let( :generate ) { spec_helper_silence_stdout() { generator_full.create_history_table_migration } }

      it_behaves_like 'valid migration running'
      it_behaves_like 'migration which generates expected columns'
    end
  end

  describe 'trigger function' do
    let( :filename ) { "#{now}_create_trigger_function_for_#{table_name}.rb" }
    let( :migrator ) { Object.const_get( "CreateTriggerFunctionFor#{model_name.pluralize}" ).new }
    let( :generate ) { spec_helper_silence_stdout() { generator.create_trigger_function_migration } }

    it_behaves_like "valid file"

    context 'migration execution' do
      let( :function_name ) { "ef_date_tr_func_#{table_name}" }
      let( :sql )           { "select proname from pg_proc where proname = '#{function_name}'" }

      it_behaves_like "valid migration running"

      it 'creates and removes the function' do
        result = ActiveRecord::Base.connection.select_all( sql )
        expect( result.length ).to eq 0

        migrate_up

        result = ActiveRecord::Base.connection.select_all( sql )
        expect( result.length ).to eq 1

        migrate_down
        result = ActiveRecord::Base.connection.select_all( sql )
        expect( result.length ).to eq 0
      end

    end
  end

  describe 'trigger' do
    let( :filename ) { "#{now}_add_trigger_to_#{table_name}.rb" }
    let( :migrator ) { Object.const_get( "AddTriggerTo#{model_name.pluralize}" ).new }
    let( :generate ) { spec_helper_silence_stdout() { generator.create_trigger_migration } }

    before do
      spec_helper_silence_stdout() do

        ActiveRecord::Migration.create_table( table_name ) do | t |
          t.string     :name
          t.text       :data
          t.datetime   :effective_start
          t.datetime   :effective_end
          t.timestamps :null => false
        end
        Object.const_set( model_name, Class.new( ActiveRecord::Base ) ){} unless Object.const_defined?(model_name)

        generator.create_trigger_function_migration
        require File.join( destination_root, "#{now}_create_trigger_function_for_#{table_name}.rb" )
        Object.const_get( "CreateTriggerFunctionFor#{model_name.pluralize}" ).new.up

      end
    end

    it_behaves_like 'valid file'

    context 'migration execution' do
      let( :trigger_name ) { "#{table_name}_ef_date_tr" }
      let( :sql )          { "select tgrelid, c.relname from pg_trigger t join pg_class c on c.oid = t.tgrelid where t.tgname = '#{trigger_name}'" }

      it_behaves_like 'valid migration running'

      it 'creates and removes the trigger' do
        result = ActiveRecord::Base.connection.select_all( sql )
        expect( result.length ).to eq 0

        migrate_up
        result = ActiveRecord::Base.connection.select_all( sql )
        expect( result.length ).to eq 1
        expect( result.first[ 'relname' ] ).to eq table_name

        migrate_down
        result = ActiveRecord::Base.connection.select_all( sql )
        expect( result.length ).to eq 0
      end
    end
  end

  describe 'trigger execution' do

    before do
      spec_helper_silence_stdout() do
        ActiveRecord::Migration.create_table( table_name ) do | t |
          t.text       :name
          t.text       :data
          t.timestamps :null => false
        end
        Object.const_set( model_name, Class.new( ActiveRecord::Base ) ){} unless Object.const_defined?(model_name)

        generator.create_history_table_migration
        generator.create_trigger_function_migration
        generator.create_trigger_migration

        require File.join( destination_root, "#{now}_create_history_table_for_#{table_name}.rb" )
        require File.join( destination_root, "#{now}_create_trigger_function_for_#{table_name}.rb" )
        require File.join( destination_root, "#{now}_add_trigger_to_#{table_name}.rb" )

        Object.const_get( "CreateHistoryTableFor#{model_name.pluralize}"    ).new.up
        Object.const_get( "CreateTriggerFunctionFor#{model_name.pluralize}" ).new.up
        Object.const_get( "AddTriggerTo#{model_name.pluralize}"             ).new.up

        # The history table
        history_model = "#{table_name}_history_entries".singularize.camelize
        Object.const_set( history_model, Class.new( ActiveRecord::Base ) ){} unless Object.const_defined?( history_model )
      end
    end

    let( :history_model_klass ) { Object.const_get( "#{table_name}_history_entries".singularize.camelize ) }

    context 'when creating a record' do
      it 'only creates one record' do
        r = model_klass.new
        r.data = 'data'

        expect{ r.save }.to change( model_klass, :count ).by( 1 )
      end
      it 'does not create a history record' do
        r = model_klass.new
        r.data = 'data'

        expect{ r.save }.not_to change( history_model_klass, :count )
      end
      context 'when using a uuid which is already in the history table' do
        it 'raises an error' do
          r = history_model_klass.new
          r.id = '1234_0'
          r.uuid = '1234'
          r.effective_start = time
          r.effective_end = time + 3.days
          r.save

          r = model_klass.new
          r.id = '1234'
          expect{ r.save }.to raise_error( ActiveRecord::RecordNotUnique )
        end
      end
    end

    context 'when running the trigger' do
      let( :new_time ) { Time.parse("2015-10-10T01:16:22Z") }
      before do
        @r = model_klass.new
        @r.data = 'data'
        @r.name = 'name'
        @r.save

        @r.data = 'new data'
      end

      context 'when updating a record' do

        it 'alters the data' do
          expect{ @r.save }.to_not change( model_klass, :count )
          expect( model_klass.count ).to eq 1
          expect( model_klass.first.data ).to eq 'new data'
        end

        it 'adds a new record to the history table' do
          expect{ @r.save }.to change( history_model_klass, :count ).by( 1 )
          expect( history_model_klass.count ).to eq 1
        end

        it 'the records have the correct data' do
          Timecop.freeze( new_time )
          @r.save
          expect( model_klass.first.data ).to eq 'new data'
          expect( model_klass.first.updated_at ).to eq new_time
          expect( model_klass.first.created_at ).to eq time

          expect( history_model_klass.count ).to eq 1
          r = history_model_klass.all.to_a.last
          expect( r.data ).to eq 'data'
          expect( r.uuid ).to eql "#{model_klass.first.id}"
          expect( r.id ).to be_a String
          expect( r.effective_end ).to eq new_time
          expect( r.id ).to eq "#{model_klass.first.id}_#{(new_time.to_f * 100000).to_i}"
        end

        context 'when attempting to have an updated at in the past' do
          after { ActiveRecord::Base.record_timestamps = true }

          it 'raises an exception' do
            #create a new record
            r = model_klass.new
            r.save

            #update it to create a history entry
            r.data = 'data'
            expect{ r.save }.to change( history_model_klass, :count ).by( 1 )

            # update it again but set the updated_at in the past
            ActiveRecord::Base.record_timestamps = false
            r.updated_at = time - 1.day
            r.data = 'other data'
            expect{ r.save }.to raise_error( ActiveRecord::StatementInvalid, /PG::RaiseException/ )
          end
        end
      end

      context 'when a couple of records are altered' do #this was previously causing an exception to be raised

        it 'records the changes' do
          r = model_klass.new
          r.save

          r.data = 'new data'
          r.updated_at = time
          expect{ r.save }.to change( history_model_klass, :count ).by( 1 )

          r1 = model_klass.new
          r1.data = 'data'
          r1.save

          r1.data = 'new data'
          expect{ r1.save }.to change( history_model_klass, :count ).by( 1 )
        end
      end

      context 'when deleting a record' do
        it 'removes the record with destroy' do
          expect{ @r.destroy }.to change( model_klass, :count ).by( -1 )
          expect( model_klass.count ).to eq 0
        end

        it 'removes the record with delete' do
          expect{ @r.delete }.to change( model_klass, :count ).by( -1 )
          expect( model_klass.count ).to eq 0
        end

        it 'adds the record to the history table' do
          Timecop.freeze( new_time )
          @r.delete

          expect( history_model_klass.count ).to eq 1
          r = history_model_klass.all.to_a.last
          expect( r.data ).to eq 'data'
          expect( r.uuid ).to eql "#{@r.id}"

          # cannot 'freeze' the time in the db so the below is the best we can do
          # on delete
          expect( r.id ).to_not be_nil
          expect( r.effective_end ).to_not be_nil
        end
      end

    end
  end

  context 'when two tables in the same db are effective dated' do
    it 'creates three fully effective dated tables without an exception' do

      spec_helper_silence_stdout() do
        ['r_first_tables', 'r_second_tables', 'r_third_tables'].each do |table_name|

          ActiveRecord::Migration.create_table( table_name ) do | t |
            t.text     :data
            t.text     :name
            t.timestamps null: false
          end
          model_name = table_name.singularize.camelize
          Object.const_set( model_name, Class.new( ActiveRecord::Base ) ){} unless Object.const_defined?( model_name )

          generator = Generators::EffectiveDate.new( [ table_name, "data", "name" ])

          generator.create_history_table_migration
          require File.join( destination_root, "#{now}_create_history_table_for_#{table_name}.rb" )
          Object.const_get( "CreateHistoryTableFor#{model_name.pluralize}" ).new.up

          generator.create_trigger_function_migration
          require File.join( destination_root, "#{now}_create_trigger_function_for_#{table_name}.rb" )
          Object.const_get( "CreateTriggerFunctionFor#{model_name.pluralize}" ).new.up

          generator.create_trigger_migration
          require File.join( destination_root, "#{now}_add_trigger_to_#{table_name}.rb" )
          Object.const_get( "AddTriggerTo#{model_name.pluralize}" ).new.up
        end
      end

    end
  end

  context 'concurrent tests', :threaded => true do
    before :each do

      spec_helper_silence_stdout() do
        ActiveRecord::Migration.create_table( table_name ) do | t |
          t.text     :data
          t.text     :name
          t.timestamps null: false
        end

        model_name = table_name.singularize.camelize
        Object.const_set( model_name, Class.new( ActiveRecord::Base ) ){} unless Object.const_defined?( model_name )

        generator = Generators::EffectiveDate.new( [ table_name, "data", "name" ])

        generator.create_history_table_migration
        require File.join( destination_root, "#{now}_create_history_table_for_#{table_name}.rb" )
        Object.const_get( "CreateHistoryTableFor#{model_name.pluralize}" ).new.up

        generator.create_trigger_function_migration
        require File.join( destination_root, "#{now}_create_trigger_function_for_#{table_name}.rb" )
        Object.const_get( "CreateTriggerFunctionFor#{model_name.pluralize}" ).new.up

        generator.create_trigger_migration
        require File.join( destination_root, "#{now}_add_trigger_to_#{table_name}.rb" )
        Object.const_get( "AddTriggerTo#{model_name.pluralize}" ).new.up
      end

      history_model = "#{table_name}_history_entries".singularize.camelize
      Object.const_set( history_model, Class.new( ActiveRecord::Base ) ){} unless Object.const_defined?( history_model )

      Timecop.return
    end

    after :each do

      # Must manually drop the tables which were created
      #
      spec_helper_silence_stdout() do
        ActiveRecord::Migration.drop_table( table_name )
        ActiveRecord::Migration.drop_table( "#{table_name}_history_entries" )

        Object.const_get( "CreateTriggerFunctionFor#{model_name.pluralize}" ).new.down
      end
    end

    let( :history_model_klass ) { Object.const_get( "#{table_name}_history_entries".singularize.camelize ) }

    context 'many threaded updates to one record', :threaded => true do

      # Database Cleaner will take one connection from the connection pool,
      # then we require 'n' more for 'n' threads, in case by chance all of
      # the threads end up running concurrently, each wanting a conenction.
      #
      let( :thread_count ) { 20 }
      #
      before :each do
        ActiveRecord::Base.connection_pool.disconnect!

        new_config = Service.config.database_config.dup
        new_config[ 'pool' ] = thread_count + 1

        ActiveRecord::Base.establish_connection( new_config )
      end

      after :each do
        ActiveRecord::Base.connection_pool.disconnect!
        ActiveRecord::Base.establish_connection( Service.config.database_config )
      end

      # Across many threads there should be no race conditions preventing
      # the history table from updating. For every thread there is one update,
      # so the history table count should increase by the thread count once
      # everything has finished running.
      #
      # Since ActiveRecord sets updated-at at the application level and since
      # it does not lock thread-safe across this operation, a context switch
      # might occur even in plain MRI Ruby when AR has set an updated-at, and
      # is about to save to the database, but the I/O operation allows a
      # switch to another thread. This means the later thread gets a record
      # into the database first, causing the delayed one to fail as an attempt
      # to insert an earlier record into the history chain.
      #
      # It is thus incumbent upon us to lock across the save operation, which
      # weakens this test considerably; service authors Must Just Know This
      # if operating in very tight timescales and multithreaded environments.
      #
      it 'records all updates' do
        s = Mutex.new
        r = model_klass.new
        r.save

        expect{
          threads = ( 1..thread_count ).map do | i |
            Thread.new() do
              m = model_klass.first
              m.data = i
              s.synchronize { m.save }
            end
          end
          threads.each { | t | t.join }
        }.to change( history_model_klass, :count ).by( thread_count )
      end
    end
  end
end
