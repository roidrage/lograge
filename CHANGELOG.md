# Change Log

### Unreleased

* Retrieve controller/action from payload not nested params [cd2dc08](https://github.com/roidrage/lograge/commit/cd2dc08)

### 0.4.0.pre2

* Add support for Rails 5 beta 3 [#169](https://github.com/roidrage/lograge/pull/169)

### 0.4.0.pre

* Add support for Rails 5 beta 2 [#166](https://github.com/roidrage/lograge/pull/166)
* End support for Ruby 1.9.3 and Rails 3 [#164](https://github.com/roidrage/lograge/pull/164)

### 0.3.6

* Fix an issue with LTSV formatter [#162](https://github.com/roidrage/lograge/pull/162)

### 0.3.5

* Support logging of unpermitted parameters in Rails 4+ [#154](https://github.com/roidrage/lograge/pull/154)

### 0.3.4

* Added LTSV formatter (<https://github.com/takashi>) [#138](https://github.com/roidrage/lograge/pull/138)

### 0.3.3

* Resolves #126 issues with status codes [#134](https://github.com/roidrage/lograge/pull/134)
* Resolves build failures under rails 3.2 caused by `logstash-event` dependency
* Delay loading so `config.enabled=` works from `config/initializers/*.rb` (<https://github.com/allori>) [#62](https://github.com/roidrage/lograge/pull/62)

## 0.3.2

### Fixed
* Make sure rack_cache[:verbose] can be set [#103](https://github.com/roidrage/lograge/pull/103)
* Follow hash syntax for logstash-event v1.4.x [#75](https://github.com/roidrage/lograge/pull/75)
* Log RecordNotFound as 404 [#27](https://github.com/roidrage/lograge/pull/27), [#110](https://github.com/roidrage/lograge/pull/110), [#112](https://github.com/roidrage/lograge/pull/112)

### Other
* Use https in Gemfile #104

## 0.3.1

### Fixed 2015-01-17

* Make rubocop pass

### Added

* Add formatter for lines (<https://github.com/zimbatm/lines>) [#35](https://github.com/roidrage/lograge/pull/35)
* Rubocop and rake ci task
* LICENSE.txt

### Other

* Performance optimizations (<https://github.com/splattael>) [#9](https://github.com/roidrage/lograge/pull/9)
* Add documentation on how to enable param logging [#68](https://github.com/roidrage/lograge/pull/68)
* Add missing JSON formatter to README [#77](https://github.com/roidrage/lograge/pull/77)
* Cleaning up gemspec

## 0.3.0 - 2014-03-11

### Added
* Add formatter for l2met (<https://github.com/BRMatt>) [#47](https://github.com/roidrage/lograge/pull/47)
* Add JSON formatter (<https://github.com/i0rek>) [#56](https://github.com/roidrage/lograge/pull/56)
* Add `before_format` hook (<https://github.com/i0rek>) [#59](https://github.com/roidrage/lograge/pull/59)
* Add Ruby 2.1.0 for testing on Travis CI (<https://github.com/salimane>) [#60](https://github.com/roidrage/lograge/pull/60)

### Fixed
* Update Logstash formatter for Logstash 1.2 format (<https://github.com/msaffitz>) [#55](https://github.com/roidrage/lograge/pull/55)



## Older Versions:

### Added
* Add support for Graylog2 events (Lennart Koopmann, http://github.com/lennartkoopmann)
* Add support for Logstash events (Holger Just, http://github.com/meineerde)
* Add `custom_options` to allow adding custom key-value pairs at runtime (Adam Cooper, https://github.com/adamcooper)

### Fixed
* Fix for Rails 3.2.9
* Use keys everywhere (Curt Michols, http://github.com/asenchi)
