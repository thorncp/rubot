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
      
      def self.execute(server, command, message)
        if @commands.has_key? command.to_s
          @server = server
          @message = message
          @commands[command].call
        end
      end
      
      def self.execute?(command)
        @commands.has_key? command
      end
      
      private
      attr_reader :server
      attr_reader :dispatcher
      attr_reader :message
    end
  end
end