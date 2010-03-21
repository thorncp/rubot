module Rubot
  module Irc
    class Message
      attr_accessor :destination, :body, :alias, :authenticated
      attr_reader :from
  
      def initialize(from, destination, body)
        @from = from
        @destination = destination
        @body = body
      end
    end
  end
end