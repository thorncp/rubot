require "thread"

module Rubot
  module Core
    class Dispatcher
      def initialize(config)
        @config = config
        @function_character = "!"
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
            message.body = $2.nil? ? "" : $2.strip # remove the function name from the message
            message.alias = $1.underscore
            
            # todo: handle name collisions
            controller = @controllers.find { |c| c.execute? message.alias }
            instance = controller.new
            instance.execute(server, self, message)
          end
      end
    end
  end
end