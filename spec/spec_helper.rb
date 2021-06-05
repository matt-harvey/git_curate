require "simplecov"
require "simplecov-lcov"

SimpleCov::Formatter::LcovFormatter.config do |c|
  c.report_with_single_file = true
  c.single_report_path = "coverage/lcov.info"
end

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::LcovFormatter,
])
# Fix incompatibility of simplecov-lcov with older versions of simplecov that are not expresses in its gemspec.
# https://github.com/fortissimo1997/simplecov-lcov/pull/25
# Lifted from: https://github.com/BetterErrors/better_errors/pull/489/files
unless SimpleCov.respond_to?(:branch_coverage)
  module SimpleCov
    def self.branch_coverage?
      false
    end
  end
end
SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "git_curate"
