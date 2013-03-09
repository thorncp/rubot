module Rubot
  class Message
    attr_accessor :from, :to, :text, :alias, :private

    def initialize(args = {})
      args.each { |k,v| send("#{k}=", v) }
    end

    def private_message?
      !!self.private
    end

    alias_method :pm?, :private_message?
  end
end
