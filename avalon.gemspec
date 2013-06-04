# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'avalon/version'

Gem::Specification.new do |gem|
  gem.name          = "arvicco-avalon"
  gem.version       = Avalon::VERSION
  gem.authors       = ["arvicco"]
  gem.email         = ["arvicco@gmail.com"]
  gem.description   = %q{Avalon miners monitor}
  gem.summary       = %q{Avalon miners monitor and set of helper scripts}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'faraday', '~> 0.8'

end
