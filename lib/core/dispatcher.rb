require "thread"

module Rubot
  module Core
    class Dispatcher
      
      # The value used to denote a command, this is pulled from config.
      attr_reader :function_character
      
      # The config hash that was used to create the Dispatcher instance.
      attr_reader :config
      
      # Mutex that should be used when accessing anything in <em>/resources</em>. This
      # will most likely be moved to the resource manager when it is implemented.
      attr_reader :resource_lock
      
      def initialize(config)
        @config = config
        @function_character = "!"
        
        reload
      end
      
      def reload
        load_controllers
      end
      
      def load_controllers
        @controllers = []
        Dir["app/controllers/*.rb"].each do |file|
          load file
          name = File.basename(file, ".rb")
          @controllers << eval(name.camelize)
        end
      end
      
      def handle_message(server, message)
        Thread.new do
          if message.body.start_with?(@function_character) && message.body =~ /^.([a-z_]+)( .+)?$/i
            message.body = $2.to_s.strip # remove the function name from the message
            message.alias = $1.underscore
            message.authenticated = @config["auth_list"].include?(message.from)
            
            # todo: handle name collisions
            controller = @controllers.find { |c| c.execute? message.alias }
            
            if controller.protected?(message.alias) && !message.authenticated
              server.msg(message.destination, "insufficient priviledges")
              return
            end
            
            instance = controller.new
            instance.execute(server, self, message)
          end
        end
      end
      
      def connected(server)
      end
      
      def on_quit(server)
      end
    end
  end
end