require "spec_helper"

module Rubot
  describe MessageQueue do
    before :each do
      klass = Class.new do
        include MessageQueue
        queue_method(:message) {}
      end
      @queue = klass.new
    end

    it "should define a method for an action that has been created" do
      @queue.should respond_to(:message)
    end

    it "should delay in between calls to queue methods by roughly the amount given at initialization" do
      @queue.message_delay = 0.5
      before = Time.now
      one = @queue.message "destination", "message"
      two = @queue.message "destination", "message"
      one.join
      two.join
      after = Time.now
      # don't really like this, but it's working for now
      (after - before).should be_within(0.1).of(0.5)
    end

    it "should execute queued methods in the scope of an instance" do
      class << @queue
        attr_reader :count
        queue_method(:doit) { @count = 1 }
      end

      @queue.doit("destination", "message").join
      @queue.count.should eql(1)
    end
  end
end