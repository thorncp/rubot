require "spec_helper"
require "ostruct"

module Rubot
  describe Listeners do
    before :each do
      # such a hack. todo: refactor please
      @@derp = nil
    end
    
    describe "no restrictions" do
      before :each do
        @listener = Class.new do
          extend Listeners
          listener { @@derp = 42 }
        end
      end
      
      it "should listen to any message" do
        @listener.listen(Message.new(text: "a witty statement"))
        @@derp.should eql(42)
      end
    end
    
    describe "regex match" do
      before :each do
        @listener = Class.new do
          extend Listeners
          listener(:matches => /o snap/) { @@derp = 42 }
          listener(:matches => /what up (\w+)/) { @@derp = @matches[1] }
        end
      end
      
      it "should listen to matched message" do
        @listener.listen(Message.new(text: "omg o snap irl"))
        @@derp.should eql(42)
      end
      
      it "should not listen to unmatched message" do
        @listener.listen(Message.new(text: "snap crackle pop"))
        @@derp.should_not eql(42)
      end
      
      it "should pass along capture groups" do
        @listener.listen(Message.new(text: "what up cuz"))
        @@derp.should eql("cuz")
      end
    end
    
    describe "from" do
      before :each do
        @listener = Class.new do
          extend Listeners
          listener(:from => "thorncp") { @@derp = 42 }
        end
      end
      
      it "should listen to message from specified nick" do
        @listener.listen(Message.new(from: "thorncp"))
        @@derp.should eql(42)
      end
      
      it "should not listen to message from unspecified nick" do
        @listener.listen(Message.new(from: "trollface"))
        @@derp.should_not eql(42)
      end
    end
    
    describe "to" do
      before :each do
        @listener = Class.new do
          extend Listeners
          listener(:to => "#rubot") { @@derp = 42 }
        end
      end
      
      it "should listen to message to specified location" do
        @listener.listen(Message.new(to: "#rubot"))
        @@derp.should eql(42)
      end
      
      it "should not listen to message to unspecified location" do
        @listener.listen(Message.new(to: "#ruby"))
        @@derp.should_not eql(42)
      end
    end
  end
end
