module Rubot
  module Core
    class Controller
      class << self
        attr_reader :commands
        attr_reader :listeners
        attr_reader :protected_commands
      end
      
      def self.authenticated(*symbols)
        @protected_commands = symbols.map(&:to_s)
      end
      
      def self.protected?(command)
        @protected_commands.include?("all") or @protected_commands.include?(command)
      end
      
      def self.command(*aliases, &block)
        @commands ||= {}
        aliases.each { |a| @commands[a.to_s] = block }
      end
      
      def self.listen(options = {}, &block)
        @listeners ||= {}
        @listeners[options] = block
      end
      
      def self.execute?(command)
        @commands.has_key? command
      end
      
      def execute(server, dispatcher, message)
        @server = server
        @message = message
        @dispatcher = dispatcher
        
        begin
          instance_exec &commands[message.alias]
        rescue Exception => detail
          puts detail.message
          puts detail.backtrace.join("\n")
          # todo: log
        end
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