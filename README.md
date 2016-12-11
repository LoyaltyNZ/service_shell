# Hoodoo service shell

This is an empty Hoodoo service shell. See the [Hoodoo gem](https://github.com/LoyaltyNZ/hoodoo/) and [Hoodoo Guides](https://loyaltynz.github.io/hoodoo/) for more about Hoodoo. The shell is analogous to the sort of thing obtained from [Rails](http://rubyonrails.org) with `rails new {app}`, but rather more bare-bones.

* To modify this *shell*: clone this repo, make changes and commit in the usual way.
* To create a *new service*: *install the Hoodoo Gem* directly or find some software component locally that has it already bundled; then run (perhaps with `bundle exec`) `hoodoo --help`. RBEnv users may need to run `rbenv rehash` after installing the Gem in order for the `hoodoo` executable to be available. Follow the printed (terse) usage instructions.
* In either case: use `bundle install` to install required gems, as usual.

Ruby 2.3.3 is _required_ for service development.

To get started you will need to create an implementation class in folder `service/implementations`, an interface class referring to it in `service/interfaces` and update `service.rb` so that it refers to the interface class(es); delete the guard `raise` statement. Resource descriptions are put in `service/resources`, usually within a namespace module. ActiveRecord models can be put in `service/models`. There is a `db` folder for schema and migrations; see `rake --tasks` for more. A Rails-like `config` folder includes `config/database.yml` and RSpec-based tests live inside `spec`.

There is no Rails-like magic in filenames used inside the `service` folder versus class names; any Ruby file will do, though you are encouraged to follow the usual convention of snake case filenames matching the title case class names with one class per file in general, just because it makes source code easier to navigate. *Models, however* inside `service/models` use ActiveRecord so must adhere to all ActiveRecord conventions.



## Tests

These use [`rspec`](http://rspec.info) - run them with:

```sh
bundle exec rspec
```

Coverage for existing shell template code is provided, including one simple integration test present which will run on the empty shell **but intentionally fail** once you start writing a real service implementation. Read the comments in the test source at `spec/integration/example_spec.rb` for important notes on how testing works, run `rspec` on the out-of-box empty shell if you want to verify that it's all OK, then delete the test and fill in the `service.rb` file so it doesn't `raise` the initial warning exception.

The [Hoodoo Testing Guide](https://loyaltynz.github.io/hoodoo/guides_0900_testing.html) has a lot more information and many examples.



## Session Details

If in a test environment (see "The `Service` object" section below) or you have no `MEMCACHED_HOST` environment variable set, the middleware runs its session system in testing mode and simulates a session ID. The test session includes only one permission set - a default fallback that *allows* all actions (as this is convenient for tests) - and only one scoping entry, which allows access to *all* secured HTTP headers. See the [`DEFAULT_TEST_SESSION` description in the Hoodoo RDoc documentation](https://cdn.rawgit.com/LoyaltyNZ/hoodoo/master/docs/rdoc/classes/Hoodoo/Services/Middleware.html#DEFAULT_TEST_SESSION) for more information.

Otherwise, the middleware requires the `X-Session-ID` header to be set to call the API. This ID is used to lookup the relevant session in [Memcached](http://memcached.org). You can use this "for real" in development by running a Memcached instance and configuring the session ID locally:

* In `~/.bashrc` or `.zshrc` add the following export. Don't forget `source ~/.bashrc` or `source ~/.zshrc`

    ```sh
    export MEMCACHED_HOST=localhost:11211
    ```

* Start `racksh` add your key to memcached using the dalli gem e.g.

    ```ruby
    require 'hoodoo/services'

    session = Hoodoo::Services::Session.new(
      :memcached_host = ENV[ 'MEMCACHED_HOST' ]
    )

    # ...and modify 'session' as need be, then...

    result = session.save_to_memcached

    # :fail => Memcached failure; :outdated => already out of date based
    # on Caller version; :ok => succeeded.
    ```

* Set the `X-Session-ID` in your requests to the value of `session.session_id`.



## Starting your service

* `bundle exec guard` - will start on any spare HTTP port and reload itself when files change.
* `PORT=<number> bundle exec guard` - will start on HTTP port `<number>` and reload itself when files change.
* `bundle exec rackup` - run Rack directly via Thin on port 9292, with no auto-reloading (might be useful if you're having odd bug issues that you suspect could be due to Guard).

The shell includes a `Guardfile` covering expected code locations with a commented out section that will auto-run tests if activated. Customise this as necessary.



## Debugging

To get a shell similar to the Rails console, issue command:

```sh
bundle exec racksh
```

Unless you're using an IDE with Ruby 2 support for debugging, then note that the once-standard Ruby `debugger` gem does not work on Ruby 2. We use `byebug` instead. To debug a source file, `require` first:

```ruby
require byebug
```

...then add a "breakpoint" via Ruby statement:

```ruby
byebug
```

...somewhere in your code. For more, see https://github.com/deivid-rodriguez/byebug.



## The `Service` object

A module called `Service` is defined in `environment.rb` and in the out-of-box shell contains configuration items that might be useful.

```ruby
Service.config.root - local filesystem path to service root folder
Service.config.env  - StringInquirer that gives name of development and
                      related methods
```

The `env` entry lets you do things like this:

```
$ racksh
[1] pry(main)> Service.config.env
=> "development"
[2] pry(main)> Service.config.env.production?
=> false
[3] pry(main)> Service.config.env.development?
=> true
```

This is the place to add other configuration data, e.g. via a `config/initializers/foo.rb` file, via:

```ruby
Service.configure do | config |
  config.foo = :bar
end
```



## Documentation

If you use RDoc comments within your source code, then this file, any Ruby files inside folder `service` and any inside folder `lib` (should you add one) will be run through the RDoc generator using SDoc for output. Generated documentation will be written to the `docs` folder, creating that if necessary. Open file `docs/rdoc/index.html` for the top level index. Use the following commands to build or update, or fully rebuild respectively, the documentation set:

```sh
bundle exec rake rdoc
bundle exec rake rerdoc
```



## Other Notes

* Various Rake tasks are available - run `bundle exec rake --tasks` to get a list.
* Use `RACK_ENV` where you would have used `RAILS_ENV` for a Rails application.
* ActiveSupport is included by the Gemfile but *not automatically required* as it slows down service startup due to the number of Ruby files it includes. Things like `obj.present?`, `nil.try(...)` and `HashWithIndifferentAccess` _are_ available, but only if you `require 'active_support/all'` (not recommended) or just the things you need with e.g. `require 'active_support/core_ext/string'` (recommended).



## Licence

Please see the `LICENSE` file for licence details. This is authoritative. At the time of writing - though this note might get out of date - the service shell is released under the LGPL v3; see:

* http://www.gnu.org/licenses/lgpl-3.0-standalone.html
* https://tldrlegal.com/license/gnu-lesser-general-public-license-v3-(lgpl-3)
