require "spec_helper"

module Rubot
  describe Controller do
    before :each do
      @controller = Class.new(Controller) do
        command :yo_dawg do
          "sup"
        end
      end
    end
    
    describe ".execute?" do
      it "should claim to be able to execute a defined command" do
        @controller.should satisfy { |c| c.execute?("yo_dawg") }
      end
      
      it "should not clame to execute an undefined command" do
        @controller.should_not satisfy { |c| c.execute?("invalid") }
      end
      
      it "should compare the string representation of the given param" do
        @controller.should satisfy { |c| c.execute?(:yo_dawg) }
      end
    end
    
    describe "#execute" do
      it "should execute the given command" do
        @controller.execute(:yo_dawg).should == "sup"
      end
      
      it "should raise when attempting to execute an undefined command" do
        lambda { @controller.execute :invalid }.should raise_error(NoCommandError)
      end
      
      it "should execute in the scope of an instance" do
        controller = Class.new(Controller) do
          command :test_instance_mehod do
            my_instance_mehod
          end
          
          def my_instance_mehod
          end
        end
        
        lambda { controller.execute :test_instance_mehod }.should_not raise_error
      end
    end
  end
end