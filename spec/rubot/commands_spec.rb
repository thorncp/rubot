require "spec_helper"

module Rubot
  describe Commands do
    before :each do
      @commander = Class.new do
        extend Commands
        command(:yo_dawg) { "sup" }
      end
    end
    
    describe ".execute?" do
      it "should claim to be able to execute a defined command" do
        @commander.should satisfy { |c| c.execute?("yo_dawg") }
      end
      
      it "should not claim to execute an undefined command" do
        @commander.should_not satisfy { |c| c.execute?("invalid") }
      end
      
      it "should compare the string representation of the given param" do
        @commander.should satisfy { |c| c.execute?(:yo_dawg) }
      end
    end
    
    describe ".execute" do
      it "should execute the given command" do
        @commander.execute(:yo_dawg).should == "sup"
      end
      
      it "should raise when attempting to execute an undefined command" do
        lambda { @commander.execute :invalid }.should raise_error(NoCommandError)
      end
      
      it "should execute in the scope of an instance" do
        @commander.class_exec do
          command(:test_instance_mehod) { my_instance_method }
          define_method(:my_instance_method) {}
        end
        
        lambda { @commander.execute :test_instance_mehod }.should_not raise_error
      end
    end

    describe "authorization" do
      it "should allow authorized nick to execute protected command" do
        @commander.class_exec do
          command(:locked_up_tight, :protected => true) {}
        end

        args = { :authorized => true }
        lambda { @commander.execute :locked_up_tight, args }.should_not raise_error
      end

      it "should not allow unauthorized nick to execute protected command" do
        @commander.class_exec do
          command(:locked_up_tight, :protected => true) {}
        end

        lambda { @commander.execute :locked_up_tight }.should raise_error(AuthorizationError)
      end
    end
  end
end