require "spec_helper"

module Rubot
  describe Events do
    it "should trigger defined events and execute in the scope of an instance" do
      klass = Class.new do
        def initialize(*); end
        extend Events
        on(:woot) { my_instance_method }
        define_method(:my_instance_method) {}
      end

      lambda { klass.trigger(:woot) }.should_not raise_error
    end

    it "should not raise when triggering an undefined event" do
      klass = Class.new { extend Events }
      lambda { klass.trigger(:lolwut) }.should_not raise_error
    end

    it "should claim to handle defined events" do
      klass = Class.new do
        extend Events
        on(:woot) { my_instance_method }
      end

      klass.should satisfy { |k| k.handle?(:woot) }
    end
  end
end
