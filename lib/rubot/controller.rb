require "rubot/commands"
require "rubot/listeners"

module Rubot
  class Controller
    extend Commands
    extend Listeners
    
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