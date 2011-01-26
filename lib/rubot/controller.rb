require "rubot/commands"

module Rubot
  class Controller
    extend Commands
    
    def initialize(params)
      @params = params
    end
    
    def server
      @params[:server]
    end
    
    def message
      @params[:message]
    end
  end
end