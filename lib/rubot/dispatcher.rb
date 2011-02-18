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
      args = {
        :server => server,
        :dispatcher => self,
        :message => message
      }

      if controller = find_contoller(message)
        wrap { controller.execute(message.alias, args) }
      else
        @controllers.each do |c|
          wrap { c.listen(message, args) }
        end
      end
    end

    def find_contoller(message)
      # pull function character to config
      if match = message.text.match(/^!(\w+)( .*)?$/i)
        message.alias = match[1]
        message.text.sub!("!#{match[1]}", "").strip
        @controllers.find { |c| c.execute?(match[1]) }
      end
    end

    def wrap(&block)
      # take into account the config value of :verbose,
      # that involves getting the config into this class
      Thread.new do
        begin
          block.call
        rescue RuntimeError => e
          puts e.inspect
        end
      end
    end
  end
end
