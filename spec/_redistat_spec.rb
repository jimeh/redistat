require "spec_helper"

describe Redistat do
  
  it "should have a valid redis client instance" do
    db.should_not be_nil
  end
  
  it "should be connected to the testing server" do
    db.client.port.should == 8379
    db.client.host.should == "127.0.0.1"
  end
  
  it "should be able to set and get data" do
    db.set "hello", "world"
    db.get("hello").should == "world"
    db.del("hello").should be_true
  end
  
  def db
    Redistat.redis
  end
  
end