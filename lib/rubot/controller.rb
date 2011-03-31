require "rubot/commands"
require "rubot/listeners"
require "rubot/events"

module Rubot
  class Controller
    extend Commands
    extend Listeners
    extend Events
    
    def initialize(params)
      @params = params
    end
    
    def server
      @params[:server]
    end
    
    def message
      @params[:message]
    end
    
    def dispatcher
      @params[:dispatcher]
    end
    
    def reply(text)
      destination = message.to == server.nick ? message.from : message.to
      server.message(destination, text)
    end
  end
end