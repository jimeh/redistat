require "spec_helper"

describe Redistat::Event do
  
  before(:each) do
    @scope = "PageViews"
    @label = "about_us"
    @label_hash = Digest::SHA1.hexdigest(@label)
    @date = Time.now
    @event = Redistat::Event.new(@scope, @label, {:views => 1}, @date, {:depth => :hour})
  end
  
  # it "should initialize properly"

  it "should allow changing Date" do
    @event.time.should == @date
    
    @date = Time.now
    @event.date = @date
    
    @event.time.should == @date
  end
  
  it "should allow changing Label" do
    @event.label.should == @label
    @event.label_hash.should == @label_hash
    
    @label = "contact_us"
    @label_hash = Digest::SHA1.hexdigest(@label)
    @event.label = @label
    
    @event.label.should == @label
    @event.label_hash.should == @label_hash
  end
  
end