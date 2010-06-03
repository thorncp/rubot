# rails-ish approach

## resources/greeting.rb
class Greeting < Rubot::Core::Resource
  class << self
    attr_accessor :val
  end
end

## controllers/greeting_controller.rb
class GreetingController < Rubot::Core::Controller
  # !greet Steve_ => "Hello there Steve_"
  command :greet do |options|
    # server and message are method calls that will return the appropriate objects
    server.msg(message.destination, Greeting.val % message.body)
  end
  
  # Steve_ joins #resdat => "Hello there Steve_"
  on :join do
    server.msg(message.destination, Greeting.val % message.from)
  end
  
  listen do
    # listen to all messages
  end
  
  listen :from => "Steve_" do
    # listen for all messages from Steve_
  end
  
  listen :matches => /some_regex/ do
    # listen for a message that matches a pattern
  end
  
  # initialize the resource when necessary
  on :startup, :reload do
    Greeting.val = "Hello there %s"
  end
end