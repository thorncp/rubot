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
          build_message_array(messages).each do |message|
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

    def string_to_irc_lines(str)
      str.split(" ").inject([""]) do |arr, word|
        arr.push("") if arr.last.size > 400
        arr.last << "#{word} "
        arr
      end.map(&:strip)
    end

    def build_message_array(messages)
      [*messages].each_with_index.map do |message, index|
        message.size > 400 ? string_to_irc_lines(message) : messages[index]
      end.flatten
    end
  end
end