require "thread"

module Rubot
  module Core
    # The middle man.  The Dispatcher takes incomming messages
    # from the server and determines the appropriate action to
    # take, handing the messages off to commands or listeners.
    #
    # Since:: 0.0.1
    class Dispatcher
      attr_reader :commands, :listeners, :function_character, :config, :resource_lock

      def initialize(config)
        @config = config
        @function_character = @config["function_character"]

        @auth_list = (config["auth_list"] || "").split(",")
        @resource_lock = Mutex.new
        
        reload
        # runners are only run on server connection, so there's no need them to be in reload 
        load_dir "runners", @runners = {}
      end

      def connected(server)
        run_runners(server)
      end

      def reload
        load_dir "commands", @commands = {}
        load_dir "listeners", @listeners = {}
      end

      def handle_message(server, message)		  
        if message.body =~ /^#{@function_character}([a-z_]+)( .+)?$/i
          message.body = $2.nil? ? "" : $2.strip # remove the function name from the message
          message.alias = $1.underscore.to_sym

          command = command_from_message(message)
          command.run(server, message) unless command.nil?
        elsif message.from != server.nick
          @listeners.each_value do |listener|
            listener.execute(server, message)
          end
        end
      end

      def command_from_message(message)
        command   = @commands[message.alias]        
        message.authenticated = authenticated?(message.from) unless command.nil?
        command
      end

      def authenticated?(nick)
        @auth_list.include?(nick)
      end

      def add_auth(nick)
        @auth_list << nick unless authenticated?(nick)
      end

      def remove_auth(nick)
        @auth_list.delete nick
      end

      private

      def run_runners(server)
        @runners.each_value {|runner| runner.run(server)}
      end

      def load_dir(dir, set)
        Dir["#{dir}/*.rb"].each do |file|
          load file
          file_to_instance_hash(file, set)
        end
      end

      def file_to_instance_hash(file, hash, ext = ".rb")
        name = File.basename(file, ext)
        clazz = eval(name.camelize).new(self)
        hash[name.to_sym] = clazz
        clazz.aliases.each{|aliaz| hash[aliaz] = clazz} if clazz.respond_to? :aliases
      end
    end
  end
end