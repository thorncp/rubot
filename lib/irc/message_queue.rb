module Rubot
  module Irc
    class MessageQueue
      attr_accessor :delay
  
      def initialize(delay)
        @delay = delay
        @lock = Mutex.new
        @queue = []
      end
  
      def method_missing(method, *args, &block)
        if block
          eigen_class.instance_eval do
            define_method method do |destination, *messages|
              messages.flatten.each do |message|
                @queue << {:block => block, :destination => destination, :message => message}
              end
              @lock.synchronize do
                @thread = Thread.new { flush } unless @thread && @thread.alive?
              end
            end
          end
          nil
        else
          super
        end
      end
  
      private
      def flush
        until @queue.empty?
          element = @queue.shift
          element[:block].call(element[:destination], element[:message])
          sleep @delay unless @queue.empty?
        end
      end
    end
  end
end