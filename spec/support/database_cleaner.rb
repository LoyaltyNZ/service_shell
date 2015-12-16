# Config for DatabaseCleaner - see:
#
#   https://github.com/DatabaseCleaner/database_cleaner
#
# Although your service might not require a database, the test suite
# does, in order to test some of its Generators.
#
RSpec.configure do | config |

  # This standard cleaner strategy works for most tests.
  #
  config.before( :each ) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with( :truncation )
  end

  # If you're going to use some Threads to write data within a single test,
  # wait for them to finish and examine output, you'll need a different
  # strategy (truncation, which is slow but effective). Use the 'threaded'
  # metadata to indicate this - for example:
  #
  #     context 'concurrent tests', :threaded => true do
  #       # ...
  #     end
  #
  config.before( :each, :threaded => true ) do
    DatabaseCleaner.strategy = :truncation
  end

  # A Database Cleaner start/stop is required to work with both of the
  # strategies above. You'll see problems especially with threaded tests
  # if you were to use "config.around( :each )" instead.
  #
  config.before( :each ) do
    DatabaseCleaner.start
  end
  config.after( :each ) do
    DatabaseCleaner.clean
  end

end
