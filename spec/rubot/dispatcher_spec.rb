require "spec_helper"

module Rubot
  describe Dispatcher do
    before :each do
      @dispatcher = Dispatcher.new
      
      @controller = Class.new(Controller) do
        command :yo_dawg do
        end
      end
      
      @dispatcher.instance_variable_set(:@controllers, [@controller])
    end
    
    describe "#message_received" do
      it "should execute a defined command" do
        @controller.should_receive(:execute).with("yo_dawg", anything)
        @dispatcher.message_received(nil, Message.new(text: "!yo_dawg"))
      end
      
      it "should not execute an undefined command" do
        @controller.should_not_receive(:execute)
        @dispatcher.message_received(nil, Message.new(text: "!invalid"))
      end
    end
  end
end