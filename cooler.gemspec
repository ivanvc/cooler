# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cooler/version'

Gem::Specification.new do |gem|
  gem.name          = "cooler"
  gem.version       = Cooler::VERSION
  gem.authors       = ["Ivan Valdes"]
  gem.email         = ["ivan@mohound.com"]
  gem.description   = %q{Mini ORM, agnostic to key value store databases}
  gem.summary       = %q{Mini ORM, agnostic to key value store databases}
  gem.homepage      = "http://github.com/mohound/coolio"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]


  gem.add_dependency('activesupport', '~> 3.2.0')
  gem.add_development_dependency('rspec', '~> 2.12.0')
  gem.add_development_dependency('rr', '~> 1.0.0')
  gem.add_development_dependency('autotest', '~> 4.4.0')
end
