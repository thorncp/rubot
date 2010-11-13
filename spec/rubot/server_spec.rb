require "spec_helper"

module Rubot
  describe Server do
    describe "#connection_completed" do
      def init_server(config = {})
        config.merge! :nick => "rubot"
        Class.new { include Server }.new(config).as_null_object
      end
      
      it "should send user info" do
        server = init_server
        server.should_receive(:raw).with("USER rubot rubot rubot rubot").once
        server.connection_completed
      end
      
      it "should send nick info" do
        server = init_server
        server.should_receive(:raw).with("NICK rubot").once
        server.connection_completed
      end
      
      it "should join all channels in config" do
        server = init_server(:channels => ["#rubot", "#ruby"])
        server.should_receive(:raw).with("JOIN #rubot").once
        server.should_receive(:raw).with("JOIN #ruby").once
        server.connection_completed
      end
    end
  end
end