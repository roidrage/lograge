# frozen_string_literal: true

require './lib/lograge/version'

Gem::Specification.new do |s|
  s.name        = 'lograge'
  s.version     = Lograge::VERSION
  s.authors     = ['Mathias Meyer', 'Ben Lovell', 'Michael Bianco']
  s.email       = ['meyer@paperplanes.de', 'benjamin.lovell@gmail.com', 'mike@mikebian.co']
  s.homepage    = 'https://github.com/roidrage/lograge'
  s.summary     = "Tame Rails' multi-line logging into a single line per request"
  s.description = "Tame Rails' multi-line logging into a single line per request"
  s.license     = 'MIT'

  s.metadata = {
    'rubygems_mfa_required' => 'true',
    'changelog_uri' => 'https://github.com/roidrage/lograge/blob/master/CHANGELOG.md'
  }

  # NOTE(ivy): Ruby version 2.5 is the oldest syntax supported by Rubocop.
  s.required_ruby_version = '>= 2.5'

  s.files = `git ls-files lib LICENSE.txt`.split("\n")

  # base64, bigdecimal, logger and mutex_m were extracted from the default gems in
  # Ruby 3.4; older Rails releases still `require` them, and JRuby (which
  # targets Ruby 3.4) does not bundle them, so declare them explicitly.
  # See: https://stdgems.org
  s.add_development_dependency 'base64'
  s.add_development_dependency 'bigdecimal'
  s.add_development_dependency 'logger'
  s.add_development_dependency 'mutex_m'
  # rdoc 8 depends on rbs, whose C extension cannot be built on JRuby. Keep
  # rdoc on the pre-rbs line so the JRuby test matrix can bundle.
  s.add_development_dependency 'rdoc', '< 8'
  s.add_development_dependency 'rspec', '~> 3.1'
  s.add_development_dependency 'rubocop', '~> 1.23'
  s.add_development_dependency 'simplecov', '~> 0.21'

  s.add_dependency 'actionpack',    '>= 4'
  s.add_dependency 'activesupport', '>= 4'
  s.add_dependency 'railties', '>= 4'
  s.add_dependency 'request_store', '~> 1.0'
end
