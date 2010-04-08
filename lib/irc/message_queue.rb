module Rubot
  module Irc
    # Used to queue outgoing messages with a delay, so we don't get excess flood
    # kicked for spamming. The actual actions taken can be whatever they need to
    # be. Currently they're just sending a message and sending an action to the
    # server.
    #
    # I'll rehash the Rubot::Irc::Server code with a few modifications to 
    # demonstrate how it works.
    #
    # ==== Example
    # This code initializes a message queue with a two second delay, then defines
    # two methods with different actions.
    #
    #   @message_queue = MessageQueue.new(2)
    #
    #   @message_queue.message do |destination, message|
    #     puts "MESSAGE to #{destination} with body #{message}"
    #   end
    #
    #   @message_queue.action do |destination, action|
    #     puts "ACTION to #{destination} with body #{action}"
    #   end
    #
    # After executing this code, the :message and :action methods are now available
    # for this queue. Each call to these methods adds another action to the queue
    # with the appropriate action.
    #
    # To use our newly created queue:
    #
    #   @message_queue.message "destination_one", "i'm a message"
    #   @message_queue.action "destination_two", "i'm an action"
    #   @message_queue.message "destination_one", "i'm anoter message"
    #
    # This will yield the following output:
    #
    #   MESSAGE to destination_one with body i'm a message
    #   # two second delay
    #   ACTION to destination_two with body i'm an action
    #   # two second delay
    #   MESSAGE to destination_one with body i'm another message
    #
    # These created methods are tailored for messages, and can accept string, arrays,
    # or exploded arrays as parameters, as long as the first parameter is the destination.
    # In the case of (exploded) arrays, each element in the array will be treated
    # as a separate call to the block used to create the method.
    #
    # ==== Fancy Pants Parameters
    # Assuming the code above has been executed, we can run the following:
    #
    #   @message_queue.message "destination_three", "message one", "message two", "message three"
    #   actions = ["action one", "action_two", "action_three"]
    #   @message_queue.action "destination_two", actions
    #
    # which will produce:
    #
    #   MESSAGE to destination_three with body message one
    #   # two second delay
    #   MESSAGE to destination_three with body message two
    #   # two second delay
    #   MESSAGE to destination_three with body message three
    #   # two second delay
    #   ACTION to destination_two with body action one
    #   # two second delay
    #   ACTION to destination_two with body action two
    #   # two second delay
    #   ACTION to destination_two with body action three
    class MessageQueue
      # The delay in seconds to be used.
      attr_accessor :delay
  
      # Initiliazes a new queue with the given delay.
      #
      # ==== Parameters
      # delay<Fixnum>:: Delay in seconds
      def initialize(delay)
        @delay = delay
        @lock = Mutex.new
        @queue = []
      end
  
      # This is where the magic happens. If we're sent a method we don't respond to,
      # and it contains a block, we create a new method using that block. If no block
      # is given, we forward to the base method_missing.
      #
      # This method makes an assumption about the block that's given. It is assumed
      # that the block takes two arguments, a destination and a message (This is a
      # message queue after all).
      #
      # ==== Parameters
      # method<Symbol>:: Method name
      # args<Array>:: Parameters given to the method
      # block<Proc>:: The block that was passed 
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
      # Flushes the queue, executing each action it contains
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