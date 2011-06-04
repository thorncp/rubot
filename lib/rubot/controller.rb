require "rubot/commands"
require "rubot/listeners"
require "rubot/events"
require "rubot/variable_house"

module Rubot
  class Controller
    extend Commands
    extend Listeners
    extend Events
    
    include VariableHouse
    
    def initialize(params)
      @params = params
    end

    def method_missing(sym, *args)
      if @params.include? sym
        @params[sym]
      elsif @params.include? sym.to_s
        @params[sym.to_s]
      else
        super
      end
    end

    def reply(text)
      destination = message.to == server.nick ? message.from : message.to
      server.message(destination, text)
    end
  end
end