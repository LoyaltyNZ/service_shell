# Contributions

We love getting pull requests for new features or fixes!

## Requirements

* Before you open a ticket or send a pull request, search for previous discussions about the same feature or issue. Add to the earlier ticket if you find one.
* Please follow the prevailing coding style, strange though it might seem, when making changes.
* Contributions can't be accepted without tests or necessary documentation updates. Run `bundle exec rspec` then see the coverage report in `coverage`; it must report 100%.
* When submitting a pull request, the more detail you can provide in the pull request body, the better. It helps us understand your intentions and more efficiently and accurately review the pull request.

## Workflow

* Fork the project and clone your fork as your local working copy (`git clone git@github.com:[username]/service_shell.git`).
* Create a topic branch to contain your change (`git checkout -b feature/[description]` or `git checkout -b hotfix/[description]`).
* Make changes and ensure there's still full test coverage (`bundle exec rspec`).
* If necessary, rebase your commits into logical chunks, without errors.
* Push the branch up (`git push origin feature/[description]`).
* Create a pull request against `LoyaltyNZ/service_shell` `master` branch describing what your change does and the why you think it should be merged.

## Guides

The service shell is mentioned in some of the Hoodoo Guides:

  http://loyaltynz.github.io/hoodoo/index.html

We try to maintain the Hoodoo Guides internally but this is a big effort. If you're sending in a PR which might impact upon them, it would be really great if you could include an indication of this in your pull request description. Better still, if possible follow the Hoodoo `CONTRIBUTING.md` information and send us a related pull request which includes the necessary alterations!
