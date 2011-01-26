require "spec_helper"

module Rubot
  describe Controller do
    before :each do
      @controller = Class.new(Controller) do
        command(:yo_dawg) { "sup" }
      end
    end
    
    describe ".execute" do
      it "should give the instance access to the server" do
        @controller.class_exec do
          command(:hit_the_server) { server }
        end
        server = double
        
        @controller.execute(:hit_the_server, server: server).should be server
      end
      
      it "should give the instance access to the server" do
        @controller.class_exec do
          command(:hit_the_message) { message }
        end
        message = double
        
        @controller.execute(:hit_the_message, message: message).should be message
      end
    end
  end
end