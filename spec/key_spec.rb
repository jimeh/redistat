require "spec_helper"

describe Redistat::Key do
  
  before(:each) do
    @scope = "PageViews"
    @label = "/about/us"
    @label_hash = Digest::SHA1.hexdigest(@label)
    @now = Time.now
    @key = Redistat::Key.new(@scope, @label, @now, {:depth => :day})
  end
  
  it "should initialize new keys properly" do
    @key.scope.should == @scope
    @key.label.should be_instance_of(Redistat::Label)
    @key.label.name.should == @label
    @key.label.hash.should == @label_hash
    @key.date.should be_instance_of(Redistat::Date)
    @key.date.to_time.to_s.should == @now.to_s
  end
  
  it "should convert to string properly" do
    @key.to_s.should == "#{@scope}/#{@label_hash}:" + [:year, :month, :day].map { |k| @now.send(k).to_s.rjust(2, '0') }.join
    props = [:year, :month, :day, :hour, :min, :sec]
    props.each do
      @key.to_s(props.last).should == "#{@scope}/#{@label_hash}:" + props.map { |k| @now.send(k).to_s.rjust(2, '0') if !k.nil? }.join
      props.pop
    end
  end
  
end