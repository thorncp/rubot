require "spec_helper"

module Rubot
  describe Authorization do
    before :each do
      klass = Class.new { include Authorization }
      @authorizer = klass.new
    end

    it "should authorize added nicks" do
      @authorizer.authorize "thorncp"
      @authorizer.should satisfy { |a| a.authorized? "thorncp" }
    end

    it "should not authorize nicks that haven't been added" do
      @authorizer.should_not satisfy { |a| a.authorized? "thorncp" }
    end

    it "should not authorize nicks that have been removed" do
      @authorizer.authorize "thorncp"
      @authorizer.deauthorize "thorncp"
      @authorizer.should_not satisfy { |a| a.authorized? "thorncp" }
    end
    
    it "should not authorize nicks that have been removed after being added twice" do
      @authorizer.authorize "thorncp"
      @authorizer.authorize "thorncp"
      @authorizer.deauthorize "thorncp"
      @authorizer.should_not satisfy { |a| a.authorized? "thorncp" }
    end
  end
end
