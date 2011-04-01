module Rubot
  module Events
    def on(event, &block)
      events[event.to_s] << block
    end

    def trigger(name, *args)
      events[name.to_s].each do |event|
        self.new(args).instance_exec(&event)
      end
    end

    def events
      # key: event type, value: array of blocks to execute
      @events ||= Hash.new { |h,k| h[k] = [] }
    end
  end
end