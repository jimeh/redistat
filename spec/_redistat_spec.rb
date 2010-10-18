require "spec_helper"

describe Redistat do
  include Redistat::Database
  
  before(:each) do
    db.flushdb
  end
  
  it "should have a valid Redis client instance" do
    db.should_not be_nil
  end
  
  it "should be connected to the testing server" do
    db.client.port.should == 8379
    db.client.host.should == "127.0.0.1"
  end
  
  it "should be able to set and get data" do
    db.set("hello", "world")
    db.get("hello").should == "world"
    db.del("hello").should be_true
  end
  
  it "should be able to store hashes to Redis" do
    db.hset("key", "field", "1")
    db.hget("key", "field").should == "1"
    db.hincrby("key", "field", 1)
    db.hget("key", "field").should == "2"
    db.hincrby("key", "field", -1)
    db.hget("key", "field").should == "1"
  end
  
end