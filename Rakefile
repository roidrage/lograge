require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

require 'rubocop/rake_task'
RuboCop::RakeTask.new

desc 'Run specs, rubocop and reek'
task ci: %w(spec rubocop)

task default: :spec
