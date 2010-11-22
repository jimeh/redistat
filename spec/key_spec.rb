require "spec_helper"

describe Redistat::Key do
  
  before(:each) do
    @scope = "PageViews"
    @label = "about_us"
    @label_hash = Digest::SHA1.hexdigest(@label)
    @date = Time.now
    @key = Redistat::Key.new(@scope, @label, @date, {:depth => :hour})
  end
  
  it "should initialize properly" do
    @key.scope.should == @scope
    @key.label.should == @label
    @key.label_hash.should == @label_hash
    @key.date.should be_instance_of(Redistat::Date)
    @key.date.to_time.to_s.should == @date.to_s
  end
  
  it "should convert to string properly" do
    @key.to_s.should == "#{@scope}/#{@label}:#{@key.date.to_s(:hour)}"
    props = [:year, :month, :day, :hour, :min, :sec]
    props.each do
      @key.to_s(props.last).should == "#{@scope}/#{@label}:#{@key.date.to_s(props.last)}"
      props.pop
    end
  end
  
  it "should abide to hashed_label option" do
    @key = Redistat::Key.new(@scope, @label, @date, {:depth => :hour, :hashed_label => true})
    @key.to_s.should == "#{@scope}/#{@label_hash}:#{@key.date.to_s(:hour)}"
    @key = Redistat::Key.new(@scope, @label, @date, {:depth => :hour, :hashed_label => false})
    @key.to_s.should == "#{@scope}/#{@label}:#{@key.date.to_s(:hour)}"
  end
  
  it "should have default depth option" do
    @key = Redistat::Key.new(@scope, @label, @date)
    @key.depth.should == :hour
  end
  
  it "should allow changing attributes" do
    # scope
    @key.scope.should == @scope
    @scope = "VisitorCount"
    @key.scope = @scope
    @key.scope.should == @scope
    # date
    @key.date.to_time.should == @date
    @date = Time.now
    @key.date = @date
    @key.date.to_time.should == @date
    # label
    @key.label.should == @label
    @key.label_hash == @label_hash
    @label = "contact_us"
    @label_hash = Digest::SHA1.hexdigest(@label)
    @key.label = @label
    @key.label.should == @label
    @key.label_hash == @label_hash
  end
  
end