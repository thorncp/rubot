module Rubot
  module Irc
    # Represents an IRC message.
    class Message
      # The location where the reply to this message should be sent. This defaults
      # to the source of the message
      attr_accessor :destination
      
      # The body of the message.
      attr_accessor :body
      
      # If the message was used to invoke a command, this will be the command name.
      attr_accessor :alias
      
      # If the user that sent this message is authenticated, this will be true.
      attr_accessor :authenticated
      
      # The user that sent this message.
      attr_reader :from
  
      # Initializes a new object with the given from, destination, and body.
      #
      # ==== Parameters
      # from<String>:: The nick who sent the message
      # destination<String>:: The destination where the reply to this message should be sent.
      # body<String>:: The body of the message
      def initialize(from, destination, body)
        @from = from
        @destination = destination
        @body = body
      end
    end
  end
end