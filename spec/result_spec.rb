require "spec_helper"

describe Redistat::Result do

  it "should should initialize properly" do
    options = {:from => "from", :till => "till"}
    result = Redistat::Result.new(options)
    result.from.should == "from"
    result.till.should == "till"
  end

  it "should have set_or_incr method" do
    result = Redistat::Result.new
    result[:world].should be_nil
    result.set_or_incr(:world, 3)
    result[:world].should == 3
    result.set_or_incr(:world, 8)
    result[:world].should == 11
  end

end
