require "spec_helper"
require "model_helper"

describe Redistat::Model do
  include Redistat::Database
  
  before(:each) do
    ModelHelper1.redis.flushdb
    ModelHelper2.redis.flushdb
    ModelHelper3.redis.flushdb
  end
  
  it "should should name itself correctly" do
    ModelHelper1.send(:name).should == "ModelHelper1"
    ModelHelper2.send(:name).should == "ModelHelper2"
  end
  
  it "should listen to model-defined options" do
    ModelHelper2.depth.should == :day
    ModelHelper2.store_event.should == true
    ModelHelper2.hashed_label.should == true
    
    ModelHelper1.depth.should == nil
    ModelHelper1.store_event.should == nil
    ModelHelper1.hashed_label.should == nil
    ModelHelper1.depth(:hour)
    ModelHelper1.depth.should == :hour
    ModelHelper1.store_event(true)
    ModelHelper1.store_event.should == true
    ModelHelper1.hashed_label(true)
    ModelHelper1.hashed_label.should == true
    ModelHelper1.options[:depth] = nil
    ModelHelper1.options[:store_event] = nil
    ModelHelper1.options[:hashed_label] = nil
    ModelHelper1.depth.should == nil
    ModelHelper1.store_event.should == nil
    ModelHelper1.hashed_label.should == nil
  end
  
  it "should store and fetch stats" do
    ModelHelper1.store("sheep.black", {:count => 6, :weight => 461}, 4.hours.ago)
    ModelHelper1.store("sheep.black", {:count => 2, :weight => 156})
    
    stats = ModelHelper1.fetch("sheep.black", 2.hours.ago, 1.hour.from_now)
    stats.total["count"].should == 2
    stats.total["weight"].should == 156
    stats.first.should == stats.total
    
    stats = ModelHelper1.fetch("sheep.black", 5.hours.ago, 1.hour.from_now)
    stats.total[:count].should == 8
    stats.total[:weight].should == 617
    stats.first.should == stats.total
    
    ModelHelper1.store("sheep.white", {:count => 5, :weight => 393}, 4.hours.ago)
    ModelHelper1.store("sheep.white", {:count => 4, :weight => 316})
    
    stats = ModelHelper1.fetch("sheep.white", 2.hours.ago, 1.hour.from_now)
    stats.total[:count].should == 4
    stats.total[:weight].should == 316
    stats.first.should == stats.total
    
    stats = ModelHelper1.fetch("sheep.white", 5.hours.ago, 1.hour.from_now)
    stats.total[:count].should == 9
    stats.total[:weight].should == 709
    stats.first.should == stats.total
  end
  
  it "should connect to different Redis servers on a per-model basis" do
    ModelHelper3.redis.client.db.should == 14
    
    ModelHelper3.store("sheep.black", {:count => 6, :weight => 461}, 4.hours.ago)
    ModelHelper3.store("sheep.black", {:count => 2, :weight => 156})
    
    db.keys("*").should be_empty
    ModelHelper1.redis.keys("*").should be_empty
    db("ModelHelper3").keys("*").should have(5).items
    ModelHelper3.redis.keys("*").should have(5).items
    
    stats = ModelHelper3.fetch("sheep.black", 2.hours.ago, 1.hour.from_now)
    stats.total["count"].should == 2
    stats.total["weight"].should == 156
    stats = ModelHelper3.fetch("sheep.black", 5.hours.ago, 1.hour.from_now)
    stats.total[:count].should == 8
    stats.total[:weight].should == 617
    
    ModelHelper3.connect_to(:port => 8379, :db => 13)
    ModelHelper3.redis.client.db.should == 13
    
    stats = ModelHelper3.fetch("sheep.black", 5.hours.ago, 1.hour.from_now)
    stats.total.should == {}
    
    ModelHelper3.connect_to(:port => 8379, :db => 14)
    ModelHelper3.redis.client.db.should == 14
    
    stats = ModelHelper3.fetch("sheep.black", 5.hours.ago, 1.hour.from_now)
    stats.total[:count].should == 8
    stats.total[:weight].should == 617
  end
  
end
