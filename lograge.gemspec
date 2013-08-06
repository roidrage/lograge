# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "lograge/version"

Gem::Specification.new do |s|
  s.name        = "lograge"
  s.version     = Lograge::VERSION
  s.authors     = ["Mathias Meyer"]
  s.email       = ["meyer@paperplanes.de"]
  s.homepage    = "https://github.com/roidrage/lograge"
  s.summary     = %q{Tame Rails' multi-line logging into a single line per request}
  s.description = %q{Tame Rails' multi-line logging into a single line per request}

  s.rubyforge_project = "lograge"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_development_dependency "guard-rspec"
  s.add_runtime_dependency "activesupport", '>= 3'
  s.add_runtime_dependency "actionpack", '>= 3'
  s.add_runtime_dependency "railties", '>= 3'
end
