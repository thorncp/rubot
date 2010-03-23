# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rubot"
  s.summary = "A Ruby Bot framwork for IRC"
  s.description = "A Ruby Bot framwork for IRC featuring reloadable commands and listeners."
  s.homepage = "http://github.com/thorncp/rubot"
  
  s.version = "0.0.3"
  s.date = "2010-03-20"
  
  s.authors = ["Chris Thorn"]
  s.email = "thorncp@gmail.com"
  
  s.require_paths = ["lib"]
  s.files = Dir["bin/**/*"] + Dir["lib/**/*"]
  s.extra_rdoc_files = ["README.rdoc"]
  
  s.executables << "rubot"
  
  s.rubygems_version = "1.3.6"
  s.required_rubygems_version = Gem::Requirement.new(">= 1.2")
end
