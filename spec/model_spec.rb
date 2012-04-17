require "spec_helper"
require "model_helper"

describe Redistat::Model do
  include Redistat::Database

  before(:each) do
    @time = Time.utc(2010, 8, 28, 12, 0, 0)
    ModelHelper1.redis.flushdb
    ModelHelper2.redis.flushdb
    ModelHelper3.redis.flushdb
    ModelHelper4.redis.flushdb
  end

  it "should should name itself correctly" do
    ModelHelper1.send(:name).should == "ModelHelper1"
    ModelHelper2.send(:name).should == "ModelHelper2"
  end

  it "should return a Finder" do
    two_hours_ago = 2.hours.ago
    one_hour_ago  = 1.hour.ago
    finder = ModelHelper1.find('label', two_hours_ago, one_hour_ago)
    finder.should be_a(Redistat::Finder)
    finder.options[:scope].to_s.should == 'ModelHelper1'
    finder.options[:label].to_s.should == 'label'
    finder.options[:from].should  == two_hours_ago
    finder.options[:till].should  == one_hour_ago
  end

  it "should #find_event" do
    Redistat::Event.should_receive(:find).with('ModelHelper1', 1)
    ModelHelper1.find_event(1)
  end

  it "should listen to model-defined options" do
    ModelHelper2.depth.should == :day
    ModelHelper2.store_event.should == true
    ModelHelper2.hashed_label.should == true
    ModelHelper2.scope.should be_nil

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

    ModelHelper4.scope.should == "FancyHelper"
    ModelHelper4.send(:name).should == "FancyHelper"
  end

  it "should store and fetch stats" do
    ModelHelper1.store("sheep.black", {:count => 6, :weight => 461}, @time.hours_ago(4))
    ModelHelper1.store("sheep.black", {:count => 2, :weight => 156}, @time)

    stats = ModelHelper1.fetch("sheep.black", @time.hours_ago(2), @time.hours_since(1))
    stats.total["count"].should == 2
    stats.total["weight"].should == 156
    stats.first.should == stats.total

    stats = ModelHelper1.fetch("sheep.black", @time.hours_ago(5), @time.hours_since(1))
    stats.total[:count].should == 8
    stats.total[:weight].should == 617
    stats.first.should == stats.total

    ModelHelper1.store("sheep.white", {:count => 5, :weight => 393}, @time.hours_ago(4))
    ModelHelper1.store("sheep.white", {:count => 4, :weight => 316}, @time)

    stats = ModelHelper1.fetch("sheep.white", @time.hours_ago(2), @time.hours_since(1))
    stats.total[:count].should == 4
    stats.total[:weight].should == 316
    stats.first.should == stats.total

    stats = ModelHelper1.fetch("sheep.white", @time.hours_ago(5), @time.hours_since(1))
    stats.total[:count].should == 9
    stats.total[:weight].should == 709
    stats.first.should == stats.total
  end

  it "should store and fetch grouping enabled stats" do
    ModelHelper1.store("sheep/black", {:count => 6, :weight => 461}, @time.hours_ago(4))
    ModelHelper1.store("sheep/black", {:count => 2, :weight => 156}, @time)
    ModelHelper1.store("sheep/white", {:count => 5, :weight => 393}, @time.hours_ago(4))
    ModelHelper1.store("sheep/white", {:count => 4, :weight => 316}, @time)

    stats = ModelHelper1.fetch("sheep/black", @time.hours_ago(2), @time.hours_since(1))
    stats.total["count"].should == 2
    stats.total["weight"].should == 156
    stats.first.should == stats.total

    stats = ModelHelper1.fetch("sheep/black", @time.hours_ago(5), @time.hours_since(1))
    stats.total[:count].should == 8
    stats.total[:weight].should == 617
    stats.first.should == stats.total

    stats = ModelHelper1.fetch("sheep/white", @time.hours_ago(2), @time.hours_since(1))
    stats.total[:count].should == 4
    stats.total[:weight].should == 316
    stats.first.should == stats.total

    stats = ModelHelper1.fetch("sheep/white", @time.hours_ago(5), @time.hours_since(1))
    stats.total[:count].should == 9
    stats.total[:weight].should == 709
    stats.first.should == stats.total

    stats = ModelHelper1.fetch("sheep", @time.hours_ago(2), @time.hours_since(1))
    stats.total[:count].should == 6
    stats.total[:weight].should == 472
    stats.first.should == stats.total

    stats = ModelHelper1.fetch("sheep", @time.hours_ago(5), @time.hours_since(1))
    stats.total[:count].should == 17
    stats.total[:weight].should == 1326
    stats.first.should == stats.total
  end

  it "should connect to different Redis servers on a per-model basis" do
    ModelHelper3.redis.client.db.should == 14

    ModelHelper3.store("sheep.black", {:count => 6, :weight => 461}, @time.hours_ago(4), :label_indexing => false)
    ModelHelper3.store("sheep.black", {:count => 2, :weight => 156}, @time, :label_indexing => false)

    db.keys("*").should be_empty
    ModelHelper1.redis.keys("*").should be_empty
    db("ModelHelper3").keys("*").should have(5).items
    ModelHelper3.redis.keys("*").should have(5).items

    stats = ModelHelper3.fetch("sheep.black", @time.hours_ago(2), @time.hours_since(1), :label_indexing => false)
    stats.total["count"].should == 2
    stats.total["weight"].should == 156
    stats = ModelHelper3.fetch("sheep.black", @time.hours_ago(5), @time.hours_since(1), :label_indexing => false)
    stats.total[:count].should == 8
    stats.total[:weight].should == 617

    ModelHelper3.connect_to(:port => 8379, :db => 13)
    ModelHelper3.redis.client.db.should == 13

    stats = ModelHelper3.fetch("sheep.black", @time.hours_ago(5), @time.hours_since(1), :label_indexing => false)
    stats.total.should == {}

    ModelHelper3.connect_to(:port => 8379, :db => 14)
    ModelHelper3.redis.client.db.should == 14

    stats = ModelHelper3.fetch("sheep.black", @time.hours_ago(5), @time.hours_since(1), :label_indexing => false)
    stats.total[:count].should == 8
    stats.total[:weight].should == 617
  end

  describe "Write Buffer" do
    before(:each) do
      Redistat.buffer_size = 20
    end

    after(:each) do
      Redistat.buffer_size = 0
    end

    it "should buffer calls in memory before committing to Redis" do
      14.times do
        ModelHelper1.store("sheep.black", {:count => 1, :weight => 461}, @time.hours_ago(4))
      end
      ModelHelper1.fetch("sheep.black", @time.hours_ago(5), @time.hours_since(1)).total.should == {}

      5.times do
        ModelHelper1.store("sheep.black", {:count => 1, :weight => 156}, @time)
      end
      ModelHelper1.fetch("sheep.black", @time.hours_ago(5), @time.hours_since(1)).total.should == {}

      ModelHelper1.store("sheep.black", {:count => 1, :weight => 156}, @time)
      stats = ModelHelper1.fetch("sheep.black", @time.hours_ago(5), @time.hours_since(1))
      stats.total["count"].should == 20
      stats.total["weight"].should == 7390
    end

    it "should force flush buffer when #flush(true) is called" do
      ModelHelper1.fetch("sheep.black", @time.hours_ago(5), @time.hours_since(1)).total.should == {}
      14.times do
        ModelHelper1.store("sheep.black", {:count => 1, :weight => 461}, @time.hours_ago(4))
      end
      ModelHelper1.fetch("sheep.black", @time.hours_ago(5), @time.hours_since(1)).total.should == {}
      Redistat.buffer.flush(true)

      stats = ModelHelper1.fetch("sheep.black", @time.hours_ago(5), @time.hours_since(1))
      stats.total["count"].should == 14
      stats.total["weight"].should == 6454
    end
  end

end
