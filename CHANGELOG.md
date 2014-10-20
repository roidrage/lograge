# Change Log

## Fixed
* Make rubocop pass

## Other
* Performance optimizations (<https://github.com/splattael>) #9

## Added
* Add formatter for lines (<https://github.com/zimbatm/lines>) #35
* Rubocop and rake ci task
* LICENSE.txt

### Other
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
