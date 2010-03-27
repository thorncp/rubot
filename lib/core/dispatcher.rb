require "thread"

module Rubot
  module Core
    # The middle man.  The Dispatcher takes incomming messages from the server and
    # determines the appropriate action to take, handing the messages off to commands
    # and listeners.
    class Dispatcher
      # Hash that holds instances of commands registered with the dispatcher. There
      # is a single instance of each command, with its name, and aliases, as keys
      # to that instance.
      attr_reader :commands
      
      # Hash that holds instances of listeners registered with the dispatcher. There
      # is a single instance of each listener, with its name as the key to that instance.
      attr_reader :listeners
      
      # The value used to denote a command, this is pulled from config.
      attr_reader :function_character
      
      # The config hash that was used to create the Dispatcher instance.
      attr_reader :config
      
      # Mutex that should be used when accessing anything in <em>/resources</em>. This
      # will most likely be moved to the resource manager when it is implemented.
      attr_reader :resource_lock

      # Creates an instance of Dispatcher using the given config hash. Values expected to
      # be in this hash are:
      # * function_character - The character used to denote a command
      # * auth_list - Comma separated string of authenticated users
      #
      # ==== Paramters
      # config<Hash>:: Hash containing config values
      def initialize(config)
        @config = config
        @function_character = @config["function_character"]

        @auth_list = (config["auth_list"] || "").split(",")
        @resource_lock = Mutex.new
        
        reload
        # runners are only run on server connection, so there's no need them to be in reload 
        load_dir "runners", @runners = {}
      end

      # Called when successful connection is made to a server. This is when the runners are
      # executed.
      #
      # ==== Parameters
      # server<Rubot::Irc::Server>:: The server instance that has successfully connected
      def connected(server)
        run_runners(server)
      end

      # Exposed method to reload all commands and listeners.
      def reload
        load_dir "commands", @commands = {}
        load_dir "listeners", @listeners = {}
      end

      # Determines how to handle a message from the server.  If the message fits the format
      # of a command, an attempt is made to find and execute that command. Otherwise, the
      # message is passed to the listeners.
      #
      # ==== Parameters
      # server<Rubot::Irc::Server>:: The server where the messge was received
      # message<Rubot:Irc::Message>:: The message to handle
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

      # Finds a command based on the message alias, and determines if the invoking user
      # is authenticated.
      #
      # ==== Parameters
      # message<Rubot::Irc::Message>:: The message to be used
      def command_from_message(message)
        command = @commands[message.alias]        
        message.authenticated = authenticated?(message.from) unless command.nil?
        command
      end

      # Determines if the given nick has authenticated with the bot.
      #
      # ==== Parameters
      # nick<String>:: The nick to check for auth privledges
      def authenticated?(nick)
        @auth_list.include?(nick)
      end

      # Adds nick to the authenticated list.
      #
      # ==== Parameters
      # nick<String>:: The nick to add to the authenticated list
      def add_auth(nick)
        @auth_list << nick unless authenticated?(nick)
      end

      # Removes nick from the authenticated list.
      #
      # ==== Parameters
      # nick<String>:: The nick to remove from the authenticated list
      def remove_auth(nick)
        @auth_list.delete nick
      end

      private

      # Runs all runners using the given server instance.
      #
      # ==== Parameters
      # server<Rubot::Irc::Server>:: Server instance
      def run_runners(server)
        @runners.each_value {|runner| runner.run(server)}
      end

      # Loads all files in the given directory and stores the class instances
      # in the given set. This is used to load commands, listeners, and runners.
      #
      # ==== Parameters
      # dir<String>:: Directory of files to load
      # set<Hash>:: Hash to store class instances in
      def load_dir(dir, set)
        Dir["#{dir}/*.rb"].each do |file|
          load file
          file_to_instance_hash(file, set)
        end
      end

      # Takes a file and creates an instance of the class within the file and stores it
      # in hash, with the base filename as the key. If the class instance responds to 
      # :aliases, these are used as keys to the instance as well.
      #
      # ==== Parameters
      # file<String>:: Filename to use for instantiation
      # hash<Hash>:: Hash to store the instance in
      # ext<String>:: File extension of the file to load
      def file_to_instance_hash(file, hash, ext = ".rb")
        name = File.basename(file, ext)
        clazz = eval(name.camelize).new(self)
        hash[name.to_sym] = clazz
        clazz.aliases.each{|aliaz| hash[aliaz] = clazz} if clazz.respond_to? :aliases
      end
    end
  end
end