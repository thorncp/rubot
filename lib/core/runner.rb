module Rubot
  module Core
    # Base class for all runners. Runners are intended to be executed upon
    # successful connection to a server, and cannot be invoked from a user.
    #
    # ==== Example
    # This runner greets every channel the bot is in upon server connection.
    #   class Greet < Rubot::Core::Runner
    #     def run(server)
    #       server.channels.each do |channel|
    #         server.msg(channel, "hi everybody!")
    #       end
    #     end
    #   end
    class Runner
  
      # Takes an instance of Rubot::Core::Dispatcher. Any
      # child class that needs a constructor should override
      # this method.
      #
      # ==== Parameters
      # dispatcher<Rubot::Core::Dispatcher>:: The dispatcher that was used to create
      # the instance of the runner.
      def initialize(dispatcher)
        @dispatcher = dispatcher
      end
  
      # Runs the runner with the given server.
      #
      # ==== Paramters
      # server<Rubot::Irc::Server>:: Server instance the runner should use for
      # messaging and information.
      def run(server)
      end
    end
  end
end
