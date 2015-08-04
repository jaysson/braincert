# coding: utf-8; mode: ruby
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'braincert/version'

Gem::Specification.new do |spec|
  spec.name          = "braincert"
  spec.version       = Braincert::VERSION
  spec.authors       = ["Armando Fox"]
  spec.email         = ["fox@cs.berkeley.edu"]
  spec.summary       = %q{ActiveModel-like wrapper around BrainCert.com API}
  spec.description   = %q{ActiveModel-like wrapper around BrainCert.com API}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "activemodel", "~> 3.2.0"
  spec.add_development_dependency "simplecov"

  spec.add_dependency "httparty"
  spec.add_dependency "json"
  spec.add_dependency "activesupport", "~> 3.2.0"
  spec.add_dependency "net_http_exception_fix"   # conflates >40 different HTTP errors into one exception class
end
