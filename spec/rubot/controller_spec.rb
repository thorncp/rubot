require "spec_helper"

module Rubot
  describe Controller do
    describe ".execute" do
      before :each do
        @controller = Class.new(Controller) do
          command(:yo_dawg) { "sup" }
        end
      end
      
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
    
    describe "reply" do
      before :each do
        @controller = Class.new(Controller)
        @server = double
        @server.stub(:nick) { "rubot" }
      end
      
      it "should reply to channel if channel message" do
        controller = @controller.new(server: @server, message: Message.new(from: "thorncp", to: "#rubot"))

        @server.should_receive(:message).with("#rubot", "hi there")
        controller.reply("hi there")
      end
      
      it "should reply to nick if private message" do
        controller = @controller.new(server: @server, message: Message.new(from: "thorncp", to: "rubot"))

        @server.should_receive(:message).with("thorncp", "hi there")
        controller.reply("hi there")
      end
    end
  end
end