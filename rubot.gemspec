# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rubot/version"

Gem::Specification.new do |s|
  s.name        = "rubot"
  s.version     = Rubot::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Chris Thorn"]
  s.email       = ["thorncp@gmail.com"]
  s.homepage    = "https://github.com/thorncp/rubot"
  s.summary     = "A Ruby Bot Framework for IRC"
  s.description = "A Ruby Bot Framework for IRC. More importantly, a project used to learn Ruby."
  
  s.required_ruby_version = "~> 1.9.2"

  s.rubyforge_project = "rubot"
  
  s.add_dependency "eventmachine", "~> 0.12"
  s.add_development_dependency "rspec", "2.4"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
