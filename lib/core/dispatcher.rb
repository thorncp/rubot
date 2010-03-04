require "thread"

module Rubot
  module Core
    class Dispatcher
  
      attr_reader :commands, :listeners, :function_character, :config, :resource_lock
  
      def initialize(config)
        @config = config
        @function_character = @config["function_character"]
    
        @auth_list = config["auth_list"].split(',')
    
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
    		  command = @commands[$1.underscore.to_sym]
		  
    		  if command.nil?
    		    puts "#{$1} does not yield a command"
    		    return
    	    end
		  
    		  #if command is protected and user is not authenticated, return
    		  if command.is_protected? && !@auth_list.include?(message.from)
    		    server.msg(message.destination, "unauthorized")
    		    return
    	    end
		  
    		  command.run(server, message)
    	  elsif message.from != server.nick
    	    @listeners.each_value do |listener|
    	      listener.execute(server, message)
          end
        end
      end
  
      def add_auth(nick)
        unless @auth_list.include? nick
          @auth_list.push nick
        end
      end
  
      def remove_auth(nick)
        @auth_list.delete nick
      end
  
      private
  
      def run_runners(server)
        @runners.each_value {|r| r.run(server)}
      end
	
    	def load_dir(dir, set = nil)
    	  Dir["#{dir}/*.rb"].each do |file|
    	    load file
	    
    	    next unless set
	    
          name = File.basename(file, ".rb")
          clazz = eval(name.camelize).new(self)
          set[name.to_sym] = clazz
          clazz.aliases.each{|a| set[a] = clazz} if clazz.respond_to? :aliases
        end
      end
    end
  end
end