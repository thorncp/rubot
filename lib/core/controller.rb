module Rubot
  module Core
    class Controller
      class << self
        attr_reader :commands
        attr_reader :listeners
      end
      
      def self.command(*aliases, &block)
        @commands ||= {}
        aliases.each { |a| @commands[a.to_s] = block }
      end
      
      def self.listen(options = {}, &block)
        @listeners ||= {}
        @listeners[options] = block
      end
      
      def execute(server, dispatcher, message)
        if commands.has_key? message.alias
          @server = server
          @message = message
          @dispatcher = dispatcher
          instance_exec &commands[message.alias]
        end
      end
      
      def self.execute?(command)
        @commands.has_key? command
      end
      
      def commands
        self.class.commands
      end
      
      private
      attr_reader :server
      attr_reader :dispatcher
      attr_reader :message
    end
  end
end