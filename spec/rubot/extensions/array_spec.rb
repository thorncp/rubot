require "spec_helper"

describe Array do
  describe "#extract_options!" do
    it "should return the last object in the array if it is a hash" do
      array = [1, 2, { :a => "bee" }]
      array.extract_options!.should == { :a => "bee" }
    end

    it "should pop the last object from the array if it is a hash" do
      array = [1, 2, { :a => "bee" }]
      array.extract_options!
      array.should == [1, 2]
    end

    it "should return an empty hash if the last object in the array is not a hash" do
      array = [1, 2]
      array.extract_options!.should == {}
    end

    it "should not modify the array if the last object in the arrary is not a hash" do
      array = [1, 2]
      array.extract_options!
      array.should == [1, 2]
    end
  end
end