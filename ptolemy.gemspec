# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ptolemy/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Natansh Verma"]
  gem.email         = ["natansh.verma@gmail.com"]
  gem.description   = %q{Ptolemy is a TOML parser.}
  gem.summary       = %q{Ptolemy is a TOML parser.}
  gem.homepage      = "http://www.github.com/natansh/ptolemy"

  gem.files         = `git ls-files`.split($\) - %w(.gitignore ptolemy.jpg)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ptolemy"
  gem.require_paths = ["lib"]
  gem.version       = Ptolemy::VERSION

  gem.required_ruby_version = ">= 1.9.3"

  gem.add_dependency "treetop"

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "guard"
  gem.add_development_dependency "guard-rspec"
end
