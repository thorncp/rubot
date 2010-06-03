## greet_resource.rb
@val = "hello_there"

## greet_command.rb
def execute(server, message, options)
  server.msg(message.destination, "#{@val}, #{message.body}")
end

## greet_listener.rb
on :join do |message|
  server.msg(message.destination, "#{@val}, #{message.from}")
end

## dispatcher.rb
# to the effect of...
class Greet
  load "greet_resource"
  load "greet_command"
  load "greet_listener"
end