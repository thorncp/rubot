require "spec_helper"

module Rubot
  describe VariableHouse do
    let :house do
      Class.new do
        include VariableHouse

        attr_reader :message

        def initialize(args = {})
          @message = Message.new(args)
        end

        controller_variable :con
        channel_variable :chan
        nick_variable :nik
      end
    end

    describe "controller variables" do
      it "should track variables across instances" do
        house.new.con = "derp"
        house.new.con.should == "derp"
      end

      it "should store variables on controller level" do
        house.new(to: "#rubot").con = "derp"
        house.new(to: "#ruby").con.should == "derp"
      end
    end

    describe "channel variables" do
      it "should track variables across instances" do
        house.new(to: "#rubot").chan = "derp"
        house.new(to: "#rubot").chan.should == "derp"
      end

      it "should store variables on channel level" do
        house.new(to: "#rubot").chan = "derp"
        house.new(to: "#ruby").chan = "herp"

        house.new(to: "#rubot").chan.should == "derp"
        house.new(to: "#ruby").chan.should == "herp"
      end
    end

    describe "nick variables" do
      it "should track variables across instances" do
        house.new(from: "thorncp").nik = "derp"
        house.new(from: "thorncp").nik.should == "derp"
      end

      it "should store variables on nick level" do
        house.new(from: "thorncp").nik = "derp"
        house.new(from: "bob").nik = "herp"

        house.new(from: "thorncp").nik.should == "derp"
        house.new(from: "bob").nik.should == "herp"
      end
    end
  end
end
