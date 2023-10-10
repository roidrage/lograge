# Change Log

### Unreleased

### 0.14.0

* Add Rails 7.1 dedicated `ActiveSupport::Deprecation` [#365](https://github.com/roidrage/lograge/pull/365)

### 0.13.0

* Add Rails 6 memory allocations to default log [#355](https://github.com/roidrage/lograge/pull/355)

### 0.12.0

* Preserve original Action Cable functionality by using `prepend` instead of redefining methods [#310](https://github.com/roidrage/lograge/pull/310)
* Return a `Rack::BodyProxy` from the `Rails::Rack::Logger` monkey patch, this ensures the same return type as Rails [#333](https://github.com/roidrage/lograge/pull/333)

* Add a new formatter `Lograge::Formatters::KeyValueDeep.new` to log object with nested key. [#282](https://github.com/roidrage/lograge/pull/282/files)

### 0.11.2

* Resolve a bug with Action Cable registration [#286](https://github.com/roidrage/lograge/pull/286)

### 0.11.1

* Resolve a bug with Action Cable registration [#289](https://github.com/roidrage/lograge/pull/289)

### 0.11.0

* Add support for Action Cable [#257](https://github.com/roidrage/lograge/pull/257)

### 0.10.0

* Strip querystring from `Location` header [#241](https://github.com/roidrage/lograge/pull/241)

### 0.9.0

* Relax Rails gem dependency [#235](https://github.com/roidrage/lograge/pull/235)

### 0.8.0

* Configure multiple base controllers [#230](https://github.com/roidrage/lograge/pull/230)

### 0.7.1

* Bug fix for configurable controllers [#228](https://github.com/roidrage/lograge/pull/228)

### 0.7.0

* Configurable base class [#227](https://github.com/roidrage/lograge/pull/227)

### 0.6.0

* Replace thread-locals with `request_store` [#218](https://github.com/roidrage/lograge/pull/218)
* An alternative to the `append_info_to_payload` strategy [#135](https://github.com/roidrage/lograge/pull/135)

### 0.5.1

* Loosen Rails gem dependency [#209](https://github.com/roidrage/lograge/pull/209)

### 0.5.0

* Rails 5.1 support [#208](https://github.com/roidrage/lograge/pull/208)

### 0.5.0.rc2

* Rails 5.1 RC2 support [#207](https://github.com/roidrage/lograge/pull/207)

### 0.5.0.rc1

* Rails 5.1 RC1 support [#205](https://github.com/roidrage/lograge/pull/205)

### 0.4.1

* Controller name is specified by class [#184](https://github.com/roidrage/lograge/pull/184)
* Loosen gemspec dependency on Rails 5 [#182](https://github.com/roidrage/lograge/pull/182)

### 0.4.0

* Rails 5 support [#181](https://github.com/roidrage/lograge/pull/181)

### 0.4.0.rc2

* Rails 5 rc2 support

### 0.4.0.rc1

* Rails 5 rc1 support [#175](https://github.com/roidrage/lograge/pull/175)

### 0.4.0.pre4

* Rails 5 beta 4 support [#174](https://github.com/roidrage/lograge/pull/174)
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
