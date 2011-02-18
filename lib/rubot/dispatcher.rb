module Rubot
  class Dispatcher
    def initialize(dir, config = {})
      @config = config
      @fc = config[:function_character] || '!'
      @controllers = []

      Dir["#{dir}/controllers/*.rb"].each do |file|
        load file
        name = File.basename(file, ".rb").camelize

        begin
          @controllers << eval(name)
        rescue NameError
          # todo: to exit or not to exit?
          puts "Could not load class #{name} from #{file}"
        end
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
      if match = message.text.match(/^#{@fc}(\w+)( .*)?$/i)
        message.alias = match[1]
        message.text.sub!("!#{match[1]}", "").strip
        @controllers.find { |c| c.execute?(match[1]) }
      end
    end

    def wrap(&block)
      Thread.new do
        begin
          block.call
        rescue RuntimeError => e
          # todo: proper logging
          puts e
        end
      end
    end

    def verbose?
      @config[:verbose]
    end
  end
end
