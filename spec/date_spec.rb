require "spec_helper"

describe Redistat::Date do
  
  it "should initialize from Time object" do
    now = Time.now
    [Redistat::Date.new(now), now.to_rs].each do |rdate|
      Redistat::Date::DEPTHS.each { |k| rdate.send(k).should == now.send(k) }
    end
  end
  
  it "should initialize from Date object" do
    today = Date.today
    [Redistat::Date.new(today), today.to_rs].each do |rdate|
      [:year, :month, :day].each { |k| rdate.send(k).should == today.send(k) }
      [:hour, :min, :sec, :usec].each { |k| rdate.send(k).should == 0 }
    end
  end
  
  it "should initialize from Fixnum object (UNIX Timestamp)" do
    now = Time.now.to_i
    time = Time.at(now)
    [Redistat::Date.new(now), now.to_rs].each do |rdate|
      [:year, :month, :day, :hour, :min, :sec].each { |k| rdate.send(k).should == time.send(k) }
    end
  end
  
  it "should initialize from String object" do
    now = Time.now
    rdate = Redistat::Date.new(now.to_s)
    [:year, :month, :day, :hour, :min, :sec].each { |k| rdate.send(k).should == now.send(k) }
  end
  
  it "should initialize from Redistat date String" do
    now = Time.now
    rdate = Redistat::Date.new(now.to_s)
    [:year, :month, :day, :hour, :min, :sec].each { |k|
      rdate.to_s(k).should == Redistat::Date.new(rdate.to_s(k)).to_s(k)
    }
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
  
  it "should convert to Fixnum object (UNIX Timestamp)" do
    now = Time.now
    rdate = Redistat::Date.new(now)
    rdate.to_i.should == now.to_i
  end
  
  it "should convert to string with correct depths" do
    today = Date.today
    now = Time.now
    [[now, Redistat::Date.new(now)], [today, Redistat::Date.new(today)]].each do |current, rdate|
      props = [:year, :month, :day, :hour, :min, :sec, nil]
      if rdate.usec > 0
        rdate.to_s(:usec).should == props.map { |k| current.send(k).to_s.rjust(2, '0') if !k.nil? }.join + "." + current.usec.to_s.rjust(6, '0')
      end
      props.clone.each do
        rdate.to_s(props.last).should == props.map { |k| current.send(k).to_s.rjust(2, '0') if !k.nil? }.join
        props.pop
      end
    end
  end
  
  it "should add helper methods to Date, Time and Fixnum classes" do
    Date.today.to_time.should == Time.parse(Date.today.to_s)
    Time.now.to_i.to_time.should == Time.at(Time.now.to_i)
    Date.today.to_rs.to_date.should == Date.today
  end
  
  it "should have a depth property" do
    now = Time.now
    
    date = Redistat::Date.new(now)
    date.depth.should be_nil
    date.to_s.should == now.to_rs(:sec).to_s
    date.to_s.should == now.to_rs.to_s(:sec)
    
    date = Redistat::Date.new(now, :hour)
    date.depth.should == :hour
    date.to_s.should == now.to_rs(:hour).to_s
    date.to_s.should == now.to_rs.to_s(:hour)
  end
  
end