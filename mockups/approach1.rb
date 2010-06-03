## Notes [plain_text]
#There would have to be some hackery to share instance variables

## greet_resource.rb
class GreetResource < Rubot::Core::Resource
  def initialize
    @val = "hello there"
  end
end

## greet_command.rb
class GreetCommand < Rubot::Core::Command
  def execute(server, message, options)
    server.msg(message.destination, "#{@val}, #{message.body}")
  end
end

## greet_listener.rb
class GreetListener < Rubot::Core::Listener
  on :join do |message|
    server.msg(message.destination, "#{@val}, #{message.from}")
  end
end