# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "git_curate/version"

Gem::Specification.new do |spec|
  spec.name          = "git_curate"
  spec.version       = GitCurate::VERSION
  spec.authors       = ["Matthew Harvey"]
  spec.email         = ["software@matthewharvey.net"]

  spec.summary       = "Simple git branch curation tool"
  spec.description   = "Step through local git branches from the command line, keeping or deleting each."
  spec.homepage      = "https://github.com/matt-harvey/git_curate"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 2.1.10"

  spec.metadata = {
    "source_code_uri" => "https://github.com/matt-harvey/git_curate",
    "changelog_uri"   => "https://raw.githubusercontent.com/matt-harvey/git_curate/master/CHANGELOG.md"
  }

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "highline", "2.0.2"
  spec.add_runtime_dependency "tabulo", "1.5.1"
  spec.add_runtime_dependency "tty-screen", "0.7.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rake-version", "~> 1.0"
end
