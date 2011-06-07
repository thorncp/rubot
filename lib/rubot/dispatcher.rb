require "sqlite3"
require "sequel"

DB = Sequel.sqlite("db/development.db")

module Rubot
  class Dispatcher
    include Authorization

    def initialize(dir, config = {})
      @dir = dir
      @config = config
      @fc = config[:function_character] || '!'

      config[:authorized_nicks].each { |nick| authorize nick } if config[:authorized_nicks]

      reload(false)
    end

    def reload(trigger_event = true)
      if @controllers && @controllers.any?
        @controllers.each(&:init)
      end
      
      load_resources
      load_controllers

      return unless trigger_event

      wrap_all(@controllers) do |controller|
        controller.trigger :reload, :dispatcher => self
      end
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
        :message => message,
        :authorized => authorized?(message.from)
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
        message.text.sub!("#{@fc}#{match[1]}", "").strip!
        @controllers.find { |c| c.execute?(match[1]) }
      end
    end

    def wrap(&block)
      Thread.new do
        begin
          block.call
        rescue StandardError, ScriptError => e
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
      threads = wrap_all(@controllers) do |controller|
        controller.trigger :quit, :dispatcher => self
      end
      threads.each(&:join)
      exit
    end

    def connected(server)
      wrap_all(@controllers) do |controller|
        controller.trigger :connect, :dispatcher => self, :server => server
      end
    end

    def wrap_all(collection)
      collection.map do |element|
        wrap { yield element }
      end
    end
  end
end
