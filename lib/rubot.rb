module Rubot
  
  dir = File.dirname(__FILE__)
  
  # run initializers
  Dir["#{dir}/init/*.rb"].each {|file| require file}
  
  # load rubot
  require "#{dir}/extensions"
  require "#{dir}/core"
  require "#{dir}/irc"
end