require "spec_helper"

describe Redistat::Collection do

  it "should initialize properly" do
    options = {:from => "from", :till => "till", :depth => "depth"}
    result = Redistat::Collection.new(options)
    result.from.should == options[:from]
    result.till.should == options[:till]
    result.depth.should == options[:depth]
  end

  it "should have a total property" do
    col = Redistat::Collection.new()
    col.total.should == {}
    col.total = {:foo => "bar"}
    col.total.should == {:foo => "bar"}
  end

end
