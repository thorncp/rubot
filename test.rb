$:.unshift "./lib/"
require "rubot"
require "eventmachine"

EventMachine::run do
  EventMachine::connect 'irc.freenode.net', 6667, Rubot::Server, Rubot::Dispatcher.new, :nick => "rubot-edge", :verbose => true, :channels => ["#rubot"]
end