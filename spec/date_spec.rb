require "spec_helper"

describe Redistat::Date do
  
  it "should initialize from Time object" do
    now = Time.now
    rdate = Redistat::Date.new(now)
    [:year, :month, :day, :hour, :min, :sec].each { |k| rdate.send(k).should == now.send(k) }
  end
  
  it "should initialize from Date object" do
    today = Date.today
    rdate = Redistat::Date.new(today)
    [:year, :month, :day].each { |k| rdate.send(k).should == today.send(k) }
    [:hour, :min, :sec].each { |k| rdate.send(k).should == nil }
  end
  
  it "should initialize from String object" do
    now = Time.now
    rdate = Redistat::Date.new(now.to_s)
    [:year, :month, :day, :hour, :min, :sec].each { |k| rdate.send(k).should == now.send(k) }
  end
  
  it "should convert to Time object" do
    now = Time.now
    rdate = Redistat::Date.new(now)
    rdate.to_time.to_s.should == now.to_s
  end
  
  it "should convert to Date object" do
    today = Date.today
    rdate = Redistat::Date.new(today)
    rdate.to_date.to_s.should == today.to_s
  end
  
  it "should convert to string with correct depths" do
    today = Date.today
    rdate = Redistat::Date.new(today)
    props = [:year, :month, :day, nil]
    props.each do
      rdate.to_s(props.last).should == props.map { |k| today.send(k).to_s.rjust(2, '0') if !k.nil? }.join
      props.pop
    end
    
    now = Time.now
    rdate = Redistat::Date.new(now)
    props = [:year, :month, :day, :hour, :min, :sec, nil]
    props.each do
      rdate.to_s(props.last).should == props.map { |k| now.send(k).to_s.rjust(2, '0') if !k.nil? }.join
      props.pop
    end
  end
  
end