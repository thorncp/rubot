module Rubot
  module Core
    # Base class for all listeners. A listener cannot be called directly, but
    # <em>listens</em> to messages on a server.
    #
    # ==== Example
    # This listener responds when the bot is greeted.
    #   class Greet < Rubot::Core::Listener
    #     def execute(server, message)
    #       server.msg(message.destination, "hi #{message.from}") if message.body == "hi #{server.nick}"
    #     end
    #   end
    class Listener
      # Takes an instance of Rubot::Core::Dispatcher. Any
      # child class that needs a constructor should override
      # this method.
      #
      # ==== Parameters
      # dispatcher<Rubot::Core::Dispatcher>:: The dispatcher that was used to create
      # the instance of the listener.
      def initialize(dispatcher)
        @dispatcher = dispatcher
      end
  
      # Runs the listener with the given server and message.
      #
      # ==== Paramters
      # server<Rubot::Irc::Server>:: Server instance the listener should use for
      # messaging and information.
      # message<Rubot::Irc::Message>:: The message that invoked the command.
      def execute(server, message)
        puts "#{self} listener does not implement execute method"
      end
    end
  end
end