require "spec_helper"

module Rubot
  describe Server do
    before :each do
      config = { :nick => "rubot", :password => "derp", :channels => ["#rubot", "#ruby"] }
      @dispatcher = double
      @server = Class.new { include Server }.new(@dispatcher, config).as_null_object
    end

    describe "#raw" do
      it "should append a newline to outgoing string" do
        @server.should_receive(:send_data).with("hi there\n").once
        @server.raw("hi there")
      end

      it "should not append newline to outgoing string when one exists" do
        @server.should_receive(:send_data).with("hi there\n").once
        @server.raw("hi there\n")
      end
    end

    describe "#connection_completed" do
      before :each do
        @server.stub(:raw)
      end

      it "should send user info" do
        @server.should_receive(:raw).with("USER rubot rubot rubot rubot").once
        @server.connection_completed
      end

      it "should send nick info" do
        @server.should_receive(:raw).with("NICK rubot").once
        @server.connection_completed
      end

      it "should join all channels in config" do
        @server.should_receive(:raw).with("JOIN #rubot,#ruby").once
        @server.connection_completed
      end

      it "should send password to server" do
        @server.should_receive(:raw).with("PASS derp").once
        @server.connection_completed
      end
    end

    describe "#receive_data" do
      it "should reply to PING requests" do
        @server.should_receive(:raw).with("PONG :some.server.com").once
        @server.receive_data("PING :some.server.com")
      end

      it "should send self and a message to dispatcher when PRIVMSG received" do
        @dispatcher.should_receive(:message_received).with(@server, instance_of(Message))
        @server.receive_data(":bob!bob@bob\sPRIVMSG\s#rubot\s:hi there!")
      end

      it "should send a correctly populated message when PRIVMSG received" do
        @dispatcher.should_receive(:message_received).with(anything, message_with(from: "bob", to: "#rubot", text: "hi there!"))
        @server.receive_data(":bob!BJohnson@12.34.56\sPRIVMSG\s#rubot\s:hi there!")
      end

      it "should properly parse messages that have the same signature as IRC protocol messages" do
        @dispatcher.should_receive(:message_received).with(anything, message_with(from: "bob", to: "#rubot", text: "!raw PRIVMSG #channel :derp"))
        @server.receive_data(":bob!BJohnson@12.34.56\sPRIVMSG\s#rubot\s:!raw PRIVMSG #channel :derp")
      end

      it "should properly flag private message" do
        @dispatcher.should_receive(:message_received).with(anything, message_with(private_message?: true))
        @server.receive_data(":bob!BJohnson@12.34.56\sPRIVMSG\srubot\s:hi rubot!")
      end

      it "should not flag channel message as private" do
        @dispatcher.should_receive(:message_received).with(anything, message_with(private_message?: false))
        @server.receive_data(":bob!BJohnson@12.34.56\sPRIVMSG\s#rubot\s:hi rubot!")
      end
    end

    describe "#message" do
      it "should send PRIVMSG command" do
        @server.should_receive(:raw).with("PRIVMSG #rubot :yo dawg")
        @server.message("#rubot", "yo dawg").join # we join to make sure the thread finishes
      end
    end

    describe "#action" do
      it "should send PRIVMSG command with ACTION flag" do
        @server.should_receive(:raw).with("PRIVMSG #rubot :\001ACTION yo dawg\001")
        @server.action("#rubot", "yo dawg").join # we join to make sure the thread finishes
      end
    end
  end
end
