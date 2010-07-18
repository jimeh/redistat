require "spec_helper"

describe Redistat::Label do
  
  it "should initialize and SHA1 hash the label name" do
    name = "/about/us"
    label = Redistat::Label.new(name)
    label.name.should == name
    label.hash.should == Digest::SHA1.hexdigest(name)
  end
  
  it "should store a label hash lookup key" do
    name = "/about/us"
    label = Redistat::Label.new(name)
    label.save
    label.saved?.should be_true
    redis.get("Redistat:lables:#{label.hash}").should == name
    
    name = "/contact/us"
    label = Redistat::Label.create(name)
    label.saved?.should be_true
    redis.get("Redistat:lables:#{label.hash}").should == name
  end
  
  def redis
    Redistat.redis
  end
  
end