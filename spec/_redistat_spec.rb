require "spec_helper"

describe Redistat do
  
  it "should create a valid redis connection to correct server" do
    Redistat.redis.should_not be_nil
    Redistat.redis.client.port.should == 8379
  end
  
end