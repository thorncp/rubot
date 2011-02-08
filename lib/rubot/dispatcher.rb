module Rubot
  class Dispatcher
    def initialize(dir)
      @controllers = []
      Dir["#{dir}/controllers/*.rb"].each do |file|
        load file
        name = File.basename(file, ".rb")
        klass = eval(name.camelize)
        @controllers << klass
      end
    end
    
    def message_received(server, message)
      # todo: consider spamming all controllers with the command, and let them decide
      # for themselves whether or not to execute it. this will be how listeners will work,
      # and will make things more consistent
      #
      # hmmmm, maybe the listeners will behave like the commands currently do...
      #
      # no, it doesn't make sense for a listener to check to see if it should listen, return true,
      # then check AGAIN to find the proc to execute.
      
      args = {
        :server => server,
        :dispatcher => self,
        :message => message
      }
      
      if controller = find_contoller(message)
        controller.execute(message.alias, args)
      else
        @controllers.each { |c| c.listen(args) }
      end
    end
    
    def find_contoller(message)
      if match = message.text.match(/^!(\w+)( .*)?$/i)
        message.alias = match[1]
        message.text.sub!("!#{match[1]}", "").strip
        @controllers.find { |c| c.execute?(match[1]) }
      end
    end
  end
end