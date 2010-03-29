require "shellwords"
require "ostruct"
require "optparse"

module Rubot
  module Core
    # Base class that handles the dirty work for IRC commands.
    class Command
  
      # Takes an instance of Rubot::Core::Dispatcher. Any
      # child class that needs a constructor should override
      # this method.
      #
      # ==== Parameters
      # dispatcher<Rubot::Core::Dispatcher>:: The dispatcher that was used to create
      # the instance of the command.
      def initialize(dispatcher)
        @dispatcher = dispatcher
      end
  
      # Runs the command with the given server and message.
      #
      # ==== Parameters
      # server<Rubot::Irc::Server>:: Server instance the command should use for
      # messaging and information.
      # message<Rubot::Irc::Message>:: The message that invoked the command.
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
  
      # Whether the command is marked as protected or not (using Command::acts_as_protected).
      def protected?
        false
      end
  
      private
  
      # The internal execution of a command, called by #run. This is the method all
      # children classes should override. 
      # 
      # ==== Paramters
      # server<Rubot::Irc::Server>:: Server instance the command should use for messaging and information.
      # message<Rubot::Irc:Message>:: The message that invoked the command.
      # options<OpenStruct>:: The options that were parsed from the message that invoked the command. The
      # parsing is handled in #run
      def execute(server, message, options)
        server.msg(message.destincation, "unimplemented")
      end
  
      # Marks the command as protected. Commands that are protected can only be accessed by users who
      # are authenticated. If you only need pieces of the command to be protected, this is not the method
      # you're looking for. In that case, use Message#authenticated, which is populated automatically
      # depending on the invoking user.
      #
      # ==== Example
      #   class Quit < Rubot::Core::Command
      #     acts_as_protected
      #     
      #     def execute(server, message, options)
      #       server.quit
      #       exit
      #     end
      #   end
      def self.acts_as_protected
        define_method(:protected?) do
          true
        end
      end
  
      # Allows a command to be called by different names (aliases).
      #
      # ==== Example
      # This command can be invoked by <em>!hi</em>, <em>!hello</em>, or <em>!whats_up</em>.
      #   class Hi < Rubot::Core::Command
      #     aliases :hello, :whats_up
      #     
      #     def execute(server, message, options)
      #       server.msg(message.destination, "hi everybody!")
      #     end
      #   end
      def self.aliases(*aliases)
        define_method(:aliases) do
          aliases
        end
      end
  
      # Parses the given array using the default options (help) and any options specified
      # by the child class by overriding #options.
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
  
      # Method to be overriden by child class if extra options are to be used. Options are
      # parsed with OptParse.
      #
      # ==== Example
      #   class Hi < Rubot::Core::Command
      #     
      #     def execute(server, message, options)
      #       if options.bye
      #         server.msg(message.destination, "bye everybody!")
      #       else
      #         server.msg(message.destination, "hi everybody!")
      #       end
      #     end
      #
      #     def options(parser, options)
      #       parser.on("-b", "--bye", "Instead of saying hi, say goodbye") do |bye|
      #         options.bye = bye
      #       end
      #   end
      def options(parser, options)
      end
    end
  end
end