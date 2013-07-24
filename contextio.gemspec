# -*- encoding: utf-8 -*-

require File.expand_path('../lib/contextio/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "contextio"
  gem.version       = ContextIO.version
  gem.summary       = 'Provides interface to Context.IO'
  gem.description   = 'Provides Ruby interface to Context.IO'
  gem.license       = 'MIT'
  gem.authors       = ['Ben Hamill']
  gem.email         = %w(ben@benhamill.com)
  gem.homepage      = 'https://github.com/contextio/contextio-ruby#readme'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'oauth', '~> 0.4.5'

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rubygems-tasks',  '~> 0.2'
  gem.add_development_dependency 'rspec',           '~> 2.14'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'redcarpet'
  gem.add_development_dependency 'pry-doc'
  gem.add_development_dependency 'fakeweb'
end
