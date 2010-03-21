require "shellwords"
require "ostruct"
require "optparse"

module Rubot
  module Core
    # Base class that handles the dirty work for IRC commands.
    # All commands belong in the /commands directory and
    # inherit this class.
    #
    # Since:: 0.0.1
    class Command
  
      def initialize(dispatcher)
        @dispatcher = dispatcher
      end
  
      def run(server, message)
        if protected? && !message.authenticated
          server.msg(message.destination, "unauthorized")
          return
        end
        
        args = Shellwords.shellwords(message.body.gsub(/(')/n, "\\\\\'"))
        options = parse(args)
    
        if options.help
          # this to_s.lines.to_a business is a hack to not display the -h, --help line
          # there's got to be an easier/better way to do this. but it'll work for now
          server.msg(message.destination, options.help.to_s.lines.to_a[0..-2])
        else
          message.body = args.join(" ")
          execute(server, message, options)
        end
      end
  
      def protected?
        false
      end
  
      private
  
      # commands override this
      def execute(server, message, options)
        server.msg(message.destincation, "unimplemented")
      end
  
      def self.acts_as_protected
        define_method(:protected?) do
          true
        end
      end
  
      def self.aliases(*aliases)
        define_method(:aliases) do
          aliases
        end
      end
  
      def parse(args)
        options = OpenStruct.new
        @parser = OptionParser.new do |parser|
          parser.banner = "Usage: !#{self.class.to_s.downcase} [options]"
      
          options(parser, options)
      
          parser.on_tail("-h", "--help", "Show this message") do
            options.help = parser
          end
        end
  
        @parser.parse!(args)
        options
      end
  
      # override this to add more options in a command class
      def options(parser, options)
      end
    end
  end
end