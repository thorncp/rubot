module Rubot
  module Listeners
    def init
      super if defined?(super)
      @listeners = []
    end
    
    def listener(options = {}, &block)
      options[:all] = true if options.empty?
      options[:block] = block
      listeners << options
    end
    
    def listen(message, args = {})
      listeners.each do |listener|
        # if :all, just go ahead and go
        unless listener[:all]
          # todo: refactor
          if listener[:matches]
            next unless matches = message.text.match(listener[:matches])
          end
          
          if listener[:from]
            next unless listener[:from] == message.from
          end

          if listener[:to]
            next unless listener[:to] == message.to
          end
        end
        instance = self.new(args)
        instance.instance_variable_set(:@matches, matches)
        instance.instance_exec(&listener[:block])
      end
    end
    
    def listeners
      @listeners ||= []
    end
  end
end