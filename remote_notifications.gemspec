# -*- encoding: utf-8 -*-
require File.expand_path('../lib/remote_notifications/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["tomhuda"]
  gem.email         = ["tomhuda@tilde.io"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "remote_notifications"
  gem.require_paths = ["lib"]
  gem.version       = RemoteNotifications::VERSION

  gem.add_dependency "activesupport", ">= 3.0.15", "< 4.0"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rake"
end
