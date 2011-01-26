require "spec_helper"

module Rubot
  describe Listeners do
    describe "no restrictions" do
      before :each do
        @listener = Class.new do
          extend Listeners
          listen { 42 }
        end
      end
      
      it "should listen to any message" do
        @listener.listen(Message.new(text: "a witty statement")).should eql(42)
      end
    end
    
    describe "regex match" do
      before :each do
        @listener = Class.new do
          extend Listeners
          listen(:match => /o snap/) { 42 }
          listen(:match => /what up (\w+)/) { matches[1] }
        end
      end
      
      it "should listen to matched message" do
        @listener.listen(Message.new(text: "omg o snap irl")).should eql(42)
      end
      
      it "should not listen to unmatched message" do
        @listener.listen(Message.new(text: "snap crackle pop")).should_not eql(42)
      end
      
      it "should pass along capture groups" do
        @listener.listen(Message.new(text: "what up cuz")).should eql("cuz")
      end
    end
    
    describe "from" do
      before :each do
        @listener = Class.new do
          extend Listeners
          listen(:from => "thorncp") { 42 }
        end
      end
      
      it "should listen to message from specified nick" do
        @listener.listen(Message.new(from: "thorncp")).should eql(42)
      end
      
      it "should not listen to message from unspecified nick" do
        @listener.listen(Message.new(from: "trollface")).should_not eql(42)
      end
    end
    
    describe "to" do
      before :each do
        @listener = Class.new do
          extend Listeners
          listen(:to => "#rubot") { 42 }
        end
      end
      
      it "should listen to message to specified location" do
        @listener.listen(Message.new(to: "#rubot")).should eql(42)
      end
      
      it "should not listen to message to unspecified location" do
        @listener.listen(Message.new(to: "#ruby")).should_not eql(42)
      end
    end
  end
end
