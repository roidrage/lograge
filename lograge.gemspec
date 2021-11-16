require './lib/lograge/version'

Gem::Specification.new do |s|
  s.name        = 'lograge'
  s.version     = Lograge::VERSION
  s.authors     = ['Mathias Meyer', 'Ben Lovell']
  s.email       = ['meyer@paperplanes.de', 'benjamin.lovell@gmail.com']
  s.homepage    = 'https://github.com/roidrage/lograge'
  s.summary     = "Tame Rails' multi-line logging into a single line per request"
  s.description = "Tame Rails' multi-line logging into a single line per request"
  s.license     = 'MIT'

  s.files = `git ls-files lib LICENSE.txt`.split("\n")

  s.add_development_dependency 'rspec', '~> 3.1'
  s.add_development_dependency 'rubocop', '~> 1.23'

  s.add_runtime_dependency 'activesupport', '>= 4'
  s.add_runtime_dependency 'actionpack',    '>= 4'
  s.add_runtime_dependency 'railties',      '>= 4'
  s.add_runtime_dependency 'request_store', '~> 1.0'
end
