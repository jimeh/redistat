require "spec_helper"

describe Redistat::Key do
  
  before(:each) do
    @scope = "PageViews"
    @label = "about_us"
    @label_hash = Digest::SHA1.hexdigest(@label)
    @date = Time.now
    @key = Redistat::Key.new(@scope, @label, @date, {:depth => :day})
  end
  
  it "should initialize properly" do
    @key.scope.should == @scope
    @key.label.should == @label
    @key.label_hash.should == @label_hash
    @key.date.should be_instance_of(Redistat::Date)
    @key.date.to_time.to_s.should == @date.to_s
  end
  
  it "should convert to string properly" do
    @key.to_s.should == "#{@scope}/#{@label_hash}:#{@key.date.to_s(:day)}"
    props = [:year, :month, :day, :hour, :min, :sec]
    props.each do
      @key.to_s(props.last).should == "#{@scope}/#{@label_hash}:#{@key.date.to_s(props.last)}"
      props.pop
    end
  end
  
  it "should abide to hash_label option" do
    @key = Redistat::Key.new(@scope, @label, @date, {:depth => :day, :label_hash => true})
    @key.to_s.should == "#{@scope}/#{@label_hash}:#{@key.date.to_s(:day)}"
    
    @key = Redistat::Key.new(@scope, @label, @date, {:depth => :day, :label_hash => false})
    @key.to_s.should == "#{@scope}/#{@label}:#{@key.date.to_s(:day)}"
  end
  
  it "should allow changing Date" do
    @key.date.to_time.should == @date
    now = Time.now
    @key.date = now
    @key.date.to_time.should == now
  end
  
  it "should allow changing Label" do
    @key.label.should == @label
    @key.label_hash == @label_hash
    @label = "contact_us"
    @label_hash = Digest::SHA1.hexdigest(@label)
    @key.label = @label
    @key.label.should == @label
    @key.label_hash == @label_hash
  end
  
end