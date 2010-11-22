require "spec_helper"
require "model_helper"

describe Redistat::Model do
  include Redistat::Database
  
  before(:each) do
    db.flushdb
  end
  
  it "should should name itself correctly" do
    ModelHelper.send(:name).should == "ModelHelper"
    ModelHelper2.send(:name).should == "ModelHelper2"
  end
  
  it "should listen to model-defined options" do
    ModelHelper2.depth.should == :day
    ModelHelper2.store_event.should == true
    
    ModelHelper.depth.should == nil
    ModelHelper.store_event.should == nil
    ModelHelper.depth(:hour)
    ModelHelper.depth.should == :hour
    ModelHelper.store_event(true)
    ModelHelper.store_event.should == true
    ModelHelper.options[:depth] = nil
    ModelHelper.options[:store_event] = nil
    ModelHelper.depth.should == nil
    ModelHelper.store_event.should == nil
  end
  
  it "should store and fetch stats" do
    ModelHelper.store("sheep.black", {:count => 6, :weight => 461}, 4.hours.ago)
    ModelHelper.store("sheep.black", {:count => 2, :weight => 156})
    
    stats = ModelHelper.fetch("sheep.black", 2.hours.ago, 1.hour.from_now)
    stats.total["count"].should == 2
    stats.total["weight"].should == 156
    stats.first.should == stats.total
    
    stats = ModelHelper.fetch("sheep.black", 5.hours.ago, 1.hour.from_now)
    stats.total["count"].should == 8
    stats.total["weight"].should == 617
    stats.first.should == stats.total
    
    ModelHelper.store("sheep.white", {:count => 5, :weight => 393}, 4.hours.ago)
    ModelHelper.store("sheep.white", {:count => 4, :weight => 316})
    
    stats = ModelHelper.fetch("sheep.white", 2.hours.ago, 1.hour.from_now)
    stats.total["count"].should == 4
    stats.total["weight"].should == 316
    stats.first.should == stats.total
    
    stats = ModelHelper.fetch("sheep.white", 5.hours.ago, 1.hour.from_now)
    stats.total["count"].should == 9
    stats.total["weight"].should == 709
    stats.first.should == stats.total
  end
  
end