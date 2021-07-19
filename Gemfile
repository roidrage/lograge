source 'https://rubygems.org'

# Specify your gem's dependencies in lograge.gemspec
gemspec

gem 'pry', group: :development

group :test do
  gem 'actionpack', '~> 5'
  gem 'activerecord', '~> 5'
  gem 'logstash-event', '~> 1.2.0'
  # logstash 1.5.4 is only supported with jrjackson up to  0.2.9
  gem 'jrjackson', '~> 0.2.9', platforms: :jruby
  gem 'lines'
end
