# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include? lib
require 'souse/version'

Gem::Specification.new do |spec|
  spec.name          = "souse"
  spec.version       = Souse::VERSION
  spec.authors       = ["Johnson Denen"]
  spec.email         = ["johnson.denen@gmail.com"]
  spec.summary       = %q{Record the manual testing of your Gherkin scenarios}
  spec.description   = %q{Store your team's manual testing scenarios in Gherkin alongside your automated Cucumber tests and invoke a manual testing session with Souse.}
  spec.homepage      = "https://github.com/jdenen/souse"
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]
  spec.bindir        = "bin"
  spec.executables   = ["souse"]

  spec.add_runtime_dependency "gherkin", "~> 2.12"
  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
