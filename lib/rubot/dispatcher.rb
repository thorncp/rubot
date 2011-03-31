require "sqlite3"
require "sequel"

DB = Sequel.sqlite("db/development.db")

module Rubot
  class Dispatcher
    def initialize(dir, config = {})
      @dir = dir
      @config = config
      @fc = config[:function_character] || '!'
      
      reload
    end

    def reload
      load_controllers
      load_resources
    end

    def load_controllers
      @controllers = []

      Dir["#{@dir}/controllers/**/*.rb"].each do |file|
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

    def load_resources
      Dir["#{@dir}/resources/**/*.rb"].each do |file|
        load file
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
      if match = message.text.match(/^#{@fc}(\w+)( .*)?$/i)
        message.alias = match[1]
        message.text.sub!("!#{match[1]}", "").strip!
        @controllers.find { |c| c.execute?(match[1]) }
      end
    end

    def wrap(&block)
      Thread.new do
        begin
          block.call
        rescue StandardError => e
          # todo: proper logging
          puts "ERROR <#{e.class}>: #{e.message}"
          puts e.backtrace
        end
      end
    end

    def verbose?
      @config[:verbose]
    end

    def quit
      threads = @controllers.map do |c|
        wrap { c.trigger :quit }
      end
      threads.each(&:join)
      exit
    end
  end
end
