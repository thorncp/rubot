$:.unshift "./lib/"
require "rubot"
require "eventmachine"

class SupController < Rubot::Controller
  command :yo do
    server.message "#rubot", "what up cuz"
  end
  
  command :echo do
    unless message.text.empty?
      server.message message.to, message.text
    else
      server.message message.to, "no text"
    end
  end
end

dispatcher = Rubot::Dispatcher.new
dispatcher.instance_variable_set :@controllers, [SupController]

EventMachine::run do
  EventMachine::connect 'irc.freenode.net', 6667, Rubot::Server, dispatcher, :nick => "rubot-edge", :verbose => true, :channels => ["#rubot"]
end