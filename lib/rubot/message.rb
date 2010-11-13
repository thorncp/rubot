module Rubot
  class Message
    attr_reader :from, :to, :text
    
    def initialize(args = {})
      args.each { |k,v| instance_variable_set("@#{k}", v) }
    end
  end
end