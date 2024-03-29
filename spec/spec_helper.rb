# Distantly based upon:
#
#   https://github.com/cutalion/grape-api-example/blob/master/spec/spec_helper.rb

# First, configure the code coverage analyser. This has to be done here, not in
# an externally included file, to work properly.

require 'simplecov'
require 'simplecov-rcov'

SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/environment.rb'

  add_group 'Implementations', 'service/implementations'
  add_group 'Interfaces',      'service/interfaces'
  add_group 'Resources',       'service/resources'
  add_group 'Models',          'service/models'
  add_group 'Monkeys',         'service/monkeys'
  add_group 'Generators',      'generators'
  add_group 'Configuration',   'config'
  add_group 'Service',         'service.rb'
end

# Now wake up the test suite properly.

ENV[ 'RACK_ENV' ] = 'test'

require File.expand_path( '../../environment', __FILE__ )

# Get migrations up to date.
#
if defined?( ActiveRecord ) && defined?( ActiveRecord::Migration )
  ActiveRecord::Migration.maintain_test_schema!
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
#
Dir[ "#{ File.dirname( __FILE__ ) }/support/**/*.rb" ].sort.each { | f | require f }

# The rest of the file is mostly auto-generated.
#
RSpec.configure do | config |

  # http://stackoverflow.com/questions/1819614/how-do-i-globally-configure-rspec-to-keep-the-color-and-format-specdoc-o
  #
  # Use color in STDOUT
  config.color = true
  #
  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  #
  config.expect_with :rspec do | expectations |
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    # be_bigger_than(2).and_smaller_than(4).description
    #   # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #   # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  #
  config.mock_with :rspec do | mocks |
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  #
  # config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # Limits the available syntax to the non-monkey patched syntax that is recommended.
  # For more details, see:
  #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
  #   - http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://myronmars.to/n/dev-blog/2014/05/notable-changes-in-rspec-3#new__config_option_to_disable_rspeccore_monkey_patching
  #
  config.disable_monkey_patching!

  # This setting enables warnings. It's recommended, but in some cases may
  # be too noisy due to issues in dependencies.
  #
  config.warnings = false

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  #
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  #
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  #
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  #
  Kernel.srand config.seed
end

# For things like ActiveRecord::Migrations used during database-orientated
# tests, or for certain logger tests, have to silence +STDOUT+ chatter to
# avoid messing up RSpec's output, but we need to be sure it's restored.
#
# &block:: Block of code to call while +STDOUT+ is disabled.
#
def spec_helper_silence_stdout( &block )
  spec_helper_silence_stream( $stdout, &block )
end

# Back-end to #spec_helper_silence_stdout; can silence arbitrary streams.
#
# +stream+:: The output stream to silence, e.g. <tt>$stdout</tt>
# &block::   Block of code to call while output stream is disabled.
#
def spec_helper_silence_stream( stream, &block )
  begin
    old_stream = stream.dup
    stream.reopen( File::NULL )
    stream.sync = true

    yield

  ensure
    stream.reopen( old_stream )
    old_stream.close

  end
end
