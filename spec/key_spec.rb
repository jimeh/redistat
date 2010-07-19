require "spec_helper"

describe Redistat::Key do
  
  before(:each) do
    @scope = "PageViews"
    @label = "/about/us"
    @label_hash = Digest::SHA1.hexdigest(@label)
    @now = Time.now
    @key = Redistat::Key.new(@scope, @label, @now, {:depth => :day})
  end
  
  it "should initialize properly" do
    @key.scope.should == @scope
    @key.label.should be_instance_of(Redistat::Label)
    @key.label.name.should == @label
    @key.label.hash.should == @label_hash
    @key.date.should be_instance_of(Redistat::Date)
    @key.date.to_time.to_s.should == @now.to_s
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
    @label = "about_us"
    @key = Redistat::Key.new(@scope, @label, @now, {:depth => :day, :hash_label => false})
    @key.to_s.should == "#{@scope}/#{@label}:#{@key.date.to_s(:day)}"
  end
  
end