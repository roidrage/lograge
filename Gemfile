# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in lograge.gemspec
gemspec

gem 'pry', group: :development

group :test do
  gem 'actionpack', '~> 6'
  gem 'activerecord', '~> 6'
  # logstash does not release any gems on rubygems, but they have two gemspecs within their repo.
  # Using the tag is an attempt of having a stable version to test against where we can ensure that
  # we test against the correct code.
  gem 'logstash-event', git: 'https://github.com/elastic/logstash', tag: 'v1.5.4'
  # logstash 1.5.4 is only supported with jrjackson up to  0.2.9
  gem 'jrjackson', '~> 0.2.9', platforms: :jruby
  gem 'lines'
  gem 'thread_safe'
end
