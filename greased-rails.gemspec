# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'greased/rails/version'

Gem::Specification.new do |gem|
  gem.name          = "greased-rails"
  gem.version       = Greased::Rails::VERSION
  gem.authors       = ["Joel Van Horn"]
  gem.email         = ["joel@joelvanhorn.com"]
  gem.description   = %q{Reusable default application settings, environment variables, and deployment tasks.}
  gem.summary       = %q{Replicate common Rails application settings and environment variables using templates. Handy deployment tasks make managing your environments easier.}
  gem.homepage      = "http://github.com/joelvh/greased-rails"

  gem.add_dependency "activesupport", ">= 3.2.0"
  gem.add_dependency "railties", ">= 3.2.0"
  #figaro
  
  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib", "tasks"]
end
