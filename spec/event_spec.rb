require "spec_helper"

describe Redistat::Event do
  
  before(:each) do
    @scope = "PageViews"
    @label = "about_us"
    @label_hash = Digest::SHA1.hexdigest(@label)
    @stats = {:views => 1}
    @meta = {:user_id => 239}
    @options = {:depth => :hour}
    @date = Time.now
    @event = Redistat::Event.new(@scope, @label, @date, @stats, @meta, @options)
  end
  
  # it "should initialize properly"

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
  
end