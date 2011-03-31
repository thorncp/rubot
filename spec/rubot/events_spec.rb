require "spec_helper"

module Rubot
  describe Events do
    it "should trigger defined events" do
      klass = Class.new do
        extend Events
        on(:woot) { call_it }
      end
      
      klass.should_receive :call_it
      klass.trigger :woot
    end

    it "should not raise when triggering an undefined event" do
      klass = Class.new { extend Events }
      lambda { klass.trigger(:lolwut) }.should_not raise_error
    end
  end
end