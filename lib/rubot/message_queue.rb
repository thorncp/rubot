module Rubot
  module MessageQueue
    def queue
      @queue ||= []
    end

    def lock
      @lock ||= Mutex.new
    end

    def message_delay
      @message_delay ||= 0
    end

    attr_writer :message_delay

    def self.included(mod)
      mod.extend MessageQueueMethodDefinition
    end

    module MessageQueueMethodDefinition
      def queue_method(name, &block)
        define_method name do |destination, *messages|
          [*messages].flatten.each do |message|
            queue << { :block => block, :destination => destination, :message => message }
          end
          lock.synchronize do
            @thread = Thread.new { flush } unless @thread && @thread.alive?
          end
          @thread
        end
      end
    end

    private

    def flush
      until queue.empty?
        element = queue.shift
        instance_exec(element[:destination], element[:message], &element[:block])
        sleep message_delay unless queue.empty?
      end
    end
  end
end