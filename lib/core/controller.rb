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
          
          begin
            instance_exec &commands[message.alias]
          rescue Exception => detail
            puts detail.message
            puts detail.backtrace.join("\n")
          end
        end
      end
      
      def self.execute?(command)
        @commands.has_key? command
      end
      
      def commands
        self.class.commands
      end
      
      def message(msg)
        @server.msg(@message.destination, msg)
      end
      
      def action(msg)
        @server.action(@message.destination, msg)
      end
      
      def text
        @message.body
      end
    end
  end
end