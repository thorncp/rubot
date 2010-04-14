module Rubot
  module Core
    # Base class for all exiters. An exiter cannot be called directly, but is executed
    # when the server receives the quit message or an interrupt is triggered
    #
    # ==== Example
    # This exiter says goodbye to all channels the bot is in.
    #   class Bye < Rubot::Core::Exiter
    #     def execute(server)
    #       server.channels.each do |channel|
    #         server.msg(channel, "bye everybody!")
    #       end
    #     end
    #   end
    class Exiter
      # Takes an instance of Rubot::Core::Dispatcher. Any
      # child class that needs a constructor should override
      # this method.
      #
      # ==== Parameters
      # dispatcher<Rubot::Core::Dispatcher>:: The dispatcher that was used to create
      # the instance of the exiter.
      def initialize(dispatcher)
        @dispatcher = dispatcher
      end
  
      # Runs the exiter with the given server.
      #
      # ==== Paramters
      # server<Rubot::Irc::Server>:: Server instance the exiter should use for
      # messaging and information.
      def execute(server)
      end
    end
  end
end