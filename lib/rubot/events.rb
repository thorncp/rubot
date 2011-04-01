module Rubot
  module Events
    def on(event, &block)
      events[event.to_s] = block
    end

    def handle?(name)
      events.include? name.to_s
    end

    def trigger(name, args = {})
      self.new(args).instance_exec(&events[name.to_s]) if handle?(name)
    end

    def events
      @events ||= {}
    end
  end
end