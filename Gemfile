source 'https://rubygems.org'

# Specify your gem's dependencies in lograge.gemspec
gemspec

group :test do
  gem 'actionpack'
  # logstash does not release any gems on rubygems, but they have two gemspecs within their repo.
  # Using the tag is an attempt of having a stable version to test against where we can ensure that
  # we test against the correct code.
  gem 'logstash-event', git: 'https://github.com/elasticsearch/logstash.git', tag: '1.5'
  gem 'rubocop'
  gem 'lines'
end
