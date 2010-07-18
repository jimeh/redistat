require "spec_helper"

describe Redistat::Label do
  
  it "should initialize and SHA1 hash the label name" do
    name = "/about/us"
    label = Redistat::Label.new(name)
    label.name.should == name
    label.hash.should == Digest::SHA1.hexdigest(name)
  end
  
end