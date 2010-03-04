module Rubot
  module Core
    class Listener
      def initialize(dispatcher)
        @dispatcher = dispatcher
      end
  
      def execute(server, message)
        puts "#{self} listener does not implement execute method"
      end
    end
  end
end