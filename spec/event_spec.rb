require "spec_helper"

describe Redistat::Event do
  
  before(:each) do
    db.flushdb
    @scope = "PageViews"
    @label = "about_us"
    @label_hash = Digest::SHA1.hexdigest(@label)
    @stats = {:views => 1}
    @meta = {:user_id => 239}
    @options = {:depth => :hour}
    @date = Time.now
    @event = Redistat::Event.new(@scope, @label, @date, @stats, @meta, @options)
  end
  
  it "should initialize properly" do
    @event.id.should be_nil
    @event.scope.should == @scope
    @event.label.should == @label
    @event.label_hash.should == @label_hash
    @event.date.to_time.should == @date
    @event.stats.should == @stats
    @event.meta.should == @meta
    @event.options.should == @event.default_options.merge(@options)
  end

  it "should allow changing attributes" do
    # date
    @event.date.to_time.should == @date
    @date = Time.now
    @event.date = @date
    @event.date.to_time.should == @date
    # label
    @event.label.should == @label
    @event.label_hash.should == @label_hash
    @label = "contact_us"
    @label_hash = Digest::SHA1.hexdigest(@label)
    @event.label = @label
    @event.label.should == @label
    @event.label_hash.should == @label_hash
  end
  
  it "should increment next_id" do
    event = Redistat::Event.new("VisitorCount", @label, @date, @stats, @meta, @options)
    @event.next_id.should == 1
    event.next_id.should == 1
    @event.next_id.should == 2
    event.next_id.should == 2
  end
  
  it "should store event properly" do
    @event = Redistat::Event.new(@scope, @label, @date, @stats, @meta, @options.merge({:store_event => true}))
    @event.new?.should be_true
    @event.save
    @event.new?.should be_false
    keys = db.keys "*"
    keys.should include("#{@event.scope}#{Redistat::KEY_EVENT}#{@event.id}")
    keys.should include("#{@event.scope}#{Redistat::KEY_EVENT_IDS}")
  end
  
  it "should find event by id" do
    @event = Redistat::Event.new(@scope, @label, @date, @stats, @meta, @options.merge({:store_event => true})).save
    fetched = Redistat::Event.find(@scope, @event.id)
    @event.scope.should == fetched.scope
    @event.label.should == fetched.label
    @event.date.to_s.should == fetched.date.to_s
  end
  
  it "should store summarized statistics"
  
  def db
    Redistat.redis
  end
  
end