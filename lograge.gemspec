# -*- encoding: utf-8 -*-
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

  s.files         = `git ls-files lib`.split("\n")

  # specify any dependencies here; for example:
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'guard-rspec'
  s.add_runtime_dependency 'activesupport', '>= 3'
  s.add_runtime_dependency 'actionpack', '>= 3'
  s.add_runtime_dependency 'railties', '>= 3'
end
