# Example integration test that shows how you might do an index-like ("#list")
# test - only no service is configured in the empty service shell, so we expect
# an exception. You'd obviously delete this test in a real service!
#
# IMPORTANT:
#
# * You must always "require 'spec_helper'" in each ..._spec.rb file
#
# * Use "Rspec.describe" at the top level, since RSpec monkey patching is
#   fully disabled.
#
# * See "log/test.log" for results. It'll just contain the test run dates and
#   nothing else in this simple test case.
#
# * Open "coverage/rcov/index.html" for a code coverage report. The fact that
#   code ran doesn't mean it would've handled all possible input/execution
#   cases, so 100% code coverage doesn't mean 100% effective testing; but less
#   than 100% certainly does mean you have a test omission.

require 'spec_helper'

RSpec.describe 'shell without configured service' do
  it 'should raise an exception' do

    # See top-level "service.rb".

    expect {
      get '/v1/anything', nil, { 'CONTENT_TYPE' => 'application/json; charset=utf-8' }
    }.to raise_error(
      RuntimeError,
      "Write one or more classes in service/implementations and service/interfaces, then refer to the interfaces here via 'comprised_of'"
    )
  end
end
