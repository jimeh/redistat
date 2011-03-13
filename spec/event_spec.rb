require "spec_helper"

describe Redistat::Event do
  include Redistat::Database
  
  before(:each) do
    db.flushdb
    @scope = "PageViews"
    @label = "about_us"
    @label_hash = Digest::SHA1.hexdigest(@label)
    @stats = {:views => 1}
    @meta = {:user_id => 239}
    @options = {:depth => :hour}
    @date = Time.now
    @event = Redistat::Event.new(@scope, @label, @date, @stats, @options, @meta)
  end
  
  it "should initialize properly" do
    @event.id.should be_nil
    @event.scope.to_s.should == @scope
    @event.label.to_s.should == @label
    @event.label_hash.should == @label_hash
    @event.date.to_time.to_s.should == @date.to_s
    @event.stats.should == @stats
    @event.meta.should == @meta
    @event.options.should == @event.default_options.merge(@options)
  end

  it "should allow changing attributes" do
    # date
    @event.date.to_time.to_s.should == @date.to_s
    @date = Time.now
    @event.date = @date
    @event.date.to_time.to_s.should == @date.to_s
    # label
    @event.label.to_s.should == @label
    @event.label_hash.should == @label_hash
    @label = "contact_us"
    @label_hash = Digest::SHA1.hexdigest(@label)
    @event.label = @label
    @event.label.to_s.should == @label
    @event.label_hash.should == @label_hash
  end
  
  it "should increment next_id" do
    event = Redistat::Event.new("VisitorCount", @label, @date, @stats, @options, @meta)
    @event.next_id.should == 1
    event.next_id.should == 1
    @event.next_id.should == 2
    event.next_id.should == 2
  end
  
  it "should store event properly" do
    @event = Redistat::Event.new(@scope, @label, @date, @stats, @options.merge({:store_event => true}), @meta)
    @event.new?.should be_true
    @event.save
    @event.new?.should be_false
    keys = db.keys "*"
    keys.should include("#{@event.scope}#{Redistat::KEY_EVENT}#{@event.id}")
    keys.should include("#{@event.scope}#{Redistat::KEY_EVENT_IDS}")
  end
  
  it "should find event by id" do
    @event = Redistat::Event.new(@scope, @label, @date, @stats, @options.merge({:store_event => true}), @meta).save
    fetched = Redistat::Event.find(@scope, @event.id)
    @event.scope.to_s.should == fetched.scope.to_s
    @event.label.to_s.should == fetched.label.to_s
    @event.date.to_s.should == fetched.date.to_s
  end
  
  it "should store summarized statistics" do
    2.times do |i|
      @event = Redistat::Event.new(@scope, @label, @date, @stats, @options, @meta).save
      Redistat::Date::DEPTHS.each do |depth|
        summary = db.hgetall @event.key.to_s(depth)
        summary.should have_at_least(1).items
        summary["views"].should == (i+1).to_s
        break if depth == :hour
      end
    end
  end
  
end