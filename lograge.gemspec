require "./lib/lograge/version"

Gem::Specification.new "lograge", Lograge::VERSION do |s|
  s.authors     = ["Mathias Meyer"]
  s.email       = ["meyer@paperplanes.de"]
  s.homepage    = "https://github.com/roidrage/lograge"
  s.summary     = s.description = "Tame Rails' multi-line logging into a single line per request"
  s.license     = "MIT"
  s.files         = `git ls-files lib`.split("\n")

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_development_dependency "guard-rspec"
  s.add_runtime_dependency "activesupport", '>= 3'
  s.add_runtime_dependency "actionpack", '>= 3'
  s.add_runtime_dependency "railties", '>= 3'
end
