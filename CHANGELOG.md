# Change Log

## Unreleased

## 0.3.2

### Fixed
* Make sure rack_cache[:verbose] can be set #103
* Follow hash syntax for logstash-event v1.4.x #75
* Log RecordNotFound as 404 #27, #110, #112

### Other
* Use https in Gemfile #104

## 0.3.1

### Fixed 2015-01-17

* Make rubocop pass

### Added

* Add formatter for lines (<https://github.com/zimbatm/lines>) #35
* Rubocop and rake ci task
* LICENSE.txt

### Other

* Performance optimizations (<https://github.com/splattael>) #9
* Add documentation on how to enable param logging #68
* Add missing JSON formatter to README #77
* Cleaning up gemspec

## 0.3.0 - 2014-03-11

### Added
* Add formatter for l2met (<https://github.com/BRMatt>) #47
* Add JSON formatter (<https://github.com/i0rek>) #56
* Add `before_format` hook (<https://github.com/i0rek>) #59
* Add Ruby 2.1.0 for testing on Travis CI (<https://github.com/salimane>) #60

### Fixed
* Update Logstash formatter for Logstash 1.2 format (<https://github.com/msaffitz>) #55



## Older Versions:

### Added
* Add support for Graylog2 events (Lennart Koopmann, http://github.com/lennartkoopmann)
* Add support for Logstash events (Holger Just, http://github.com/meineerde)
* Add `custom_options` to allow adding custom key-value pairs at runtime (Adam Cooper, https://github.com/adamcooper)

### Fixed
* Fix for Rails 3.2.9
* Use keys everywhere (Curt Michols, http://github.com/asenchi)
