module Rubot
  
  dir = File.dirname(__FILE__)
  
  # load rubot
  require "#{dir}/extensions"
  require "#{dir}/core"
  require "#{dir}/irc"
end