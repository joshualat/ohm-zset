# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ohm-zset/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Josh"]
  gem.email         = ["akosijoshualat@gmail.com"]
  gem.description   = %q{Adds ZSet support to Ohm}
  gem.summary       = %q{Adds ZSet support to Ohm}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ohm-zset"
  gem.require_paths = ["lib"]
  gem.version       = Ohm::Zset::VERSION

  gem.add_dependency "ohm", "~> 2.0.0"
  gem.add_dependency "ohm-contrib", "~> 2.0.0"
  gem.add_dependency "uuidtools", "~> 2.1.3"
  gem.add_dependency "sourcify", "~> 0.5.0"
end
