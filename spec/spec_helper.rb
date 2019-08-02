require "simplecov"

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
])
SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "git_curate"
