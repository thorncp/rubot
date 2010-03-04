# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rubot"
  s.summary = "A Ruby Bot framwork for IRC"
  s.description = "A Ruby Bot framwork for IRC featuring reloadable commands and listeners."
  s.homepage = "http://github.com/thorncp/rubot"
  
  s.version = "0.0.1"
  s.date = "2010-03-04"
  
  s.authors = ["Chris Thorn"]
  s.email = "thorncp@gmail.com"
  
  s.require_paths = ["lib"]
  s.files = Dir["lib/**/*"] + ["README", "Rakefile"]
  s.extra_rdoc_files = ["README"]
  
  #s.has_rdoc = true
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "NiftyGenerators", "--main", "README.rdoc"]
  
  s.rubygems_version = "1.3.6"
  s.required_rubygems_version = Gem::Requirement.new(">= 1.2")
end
