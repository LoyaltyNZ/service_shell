# Change log

## 2.0.0

- Bump `rack` version to 3.1 [DS-4497](https://loyaltynz.atlassian.net/browse/DS-4497)
- Other gems updated:
  - Bump `faker` 3.4.1 (was 1.9.6)
  - Bump `concurrent-ruby` 1.3.3 (was 1.2.3)
  - Bump `thor` 1.3.1 (was 1.2.2)
  - Bump `method_source` 1.1.0 (was 1.0.0)
  - Bump `stringio` 3.1.1 (was 3.0.9)
  - Bump `ffi` 1.17.0 (arm64-darwin) (was 1.16.3)
  - Bump `rb-inotify` 0.11.1 (was 0.10.1)
  - Bump `rdoc` 6.7.0 (was 6.5.1.1)
  - Bump `ddtrace` 1.23.2 (was 1.23.0)
  - Bump `listen` 3.9.0 (was 3.8.0)
  - Bump `activesupport` 7.1.3.4 (was 7.1.3.3)
  - Bump `activemodel` 7.1.3.4 (was 7.1.3.3)
  - Bump `activerecord` 7.1.3.4 (was 7.1.3.3)
  - Bump `rack` 3.1.4 (was 2.2.9)
  - Bump `hoodoo` 4.0.0 (was 3.5.7)

## 1.0.8

Automated Monthly Patching Jun24
- Gems updated:
  - timecop 0.9.9 (was 0.9.8)
  - i18n 1.14.5 (was 1.14.4)
  - activesupport 7.1.3.3 (was 7.1.3.2)
  - activemodel 7.1.3.3 (was 7.1.3.2)
  - activerecord 7.1.3.3 (was 7.1.3.2)

## 1.0.7

- Moved from Travis CI to Github Actions [TO-7516](https://loyaltynz.atlassian.net/browse/TO-7516)

## 1.0.6

Automated Monthly Patching May24
- Gems updated:
  - hoodoo 3.5.7 (was 3.5.3)
  - bigdecimal 3.1.8 (was 3.1.7)
  - datadog-ci 0.8.3 (was 0.7.0)
  - ddtrace 1.23.0 (was 1.20.0)
  - ffi 1.16.3 (was 1.15.5)
  - libdatadog 7.0.0.1.0 (was 5.0.0.1.0)

## 1.0.5

Automated Monthly Patching Mar24
- Gems updated:
  - rack 2.2.9 (was 2.2.8.1)
  - rdoc 6.5.1.1 (was 6.5.0)

## 1.0.4

- Updated ActiveSupport and ActiveRecord to 7.1 (was 7.0) [DS-4129](https://loyaltynz.atlassian.net/browse/DS-4129)

## 1.0.3

Automated Monthly Patching Mar24
- Gems updated:
  - drb 2.2.1 (was 2.2.0)
  - pg 1.5.6 (was 1.5.5) with native extensions

## 1.0.2

- Updated ruby to 3.3.0 (was 3.1.2) [DS-4133](https://loyaltynz.atlassian.net/browse/DS-4133)
- Squash deprecation warnings:
  - Add to Gemfile any gems that will be removed from the standard library (https://www.ruby-lang.org/en/news/2023/12/25/ruby-3-3-0-released/)
  - `ActiveRecord::Base.default_timezone` -> `ActiveRecord.default_timezone`

## 1.0.1

- Update `activerecord` and `activesupport` to `v7.0` [DS-3685](https://loyaltynz.atlassian.net/browse/DS-3685)

## 1.0.0

- Update Ruby from `2.7.3` to `3.1.2` [DS-2919](https://loyaltynz.atlassian.net/browse/FT-2919)
- Updated Hoodoo from `2.7` to `3.3`
- Update `activerecord` and `activesupport` to `v6.0`
- When updating `activerecord` from `v5.2` to `v6.0` tests in the `spec/generators/effective_date_spec.rb`
  file were failing due to `activerecord` wrapping the expected errors in another error. tests have
  been updated to reflect this.
- Updated travis.yml to use ruby `3.1.2`

## 0.0.2

- Update Postgres to version 13.3 [FT-811](https://loyaltynz.atlassian.net/browse/FT-811)
- Added CHANGELOG.md
- Updated Ruby version to `2.7.3`
- Fixed audit vulnerabilities via `bundle update rdoc rake rack json activesupport activerecord`

## 0.0.1

Initial version
