require "spec_helper"

describe Redistat do
  
  it "should have a valid redis client instance" do
    redis.should_not be_nil
  end
  
  it "should be connected to the testing server" do
    redis.client.port.should == 8379
    redis.client.host.should == "127.0.0.1"
  end
  
  it "should be able to set and get data" do
    redis.set "hello", "world"
    redis.get("hello").should == "world"
    redis.del("hello").should be_true
  end
  
  def redis
    Redistat.redis
  end
  
end