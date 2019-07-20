require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rake-version"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

RakeVersion::Tasks.new do |v|
  v.copy "lib/git_curate/version.rb"
  v.copy "README.md", all: true
end
