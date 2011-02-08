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
  end
end