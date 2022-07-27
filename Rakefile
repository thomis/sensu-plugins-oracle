require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "standard/rake"

t = RSpec::Core::RakeTask.new(:spec)
t.verbose = false

task default: [:spec, :standard]
