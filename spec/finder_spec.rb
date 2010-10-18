require "spec_helper"

describe Redistat::Finder do
  include Redistat::Database
  
  before(:each) do
    db.flushdb
    @scope = "PageViews"
    @label = "about_us"
    @date = Time.now
    @key = Redistat::Key.new(@scope, @label, @date, {:depth => :day})
    @stats = {"views" => 3, "visitors" => 2}
  end
  
  it "should initialize properly" do
    two_hours_ago = 2.hours.ago
    one_hour_ago = 1.hour.ago
    options = {:scope => "PageViews", :label => "Label", :from => two_hours_ago, :till => one_hour_ago, :depth => :hour, :interval => :hour}
    
    finder = Redistat::Finder.new(options)
    finder.options.should == options

    finder = Redistat::Finder.dates(two_hours_ago, one_hour_ago).scope("PageViews").label("Label").depth(:hour).interval(:hour)
    finder.options.should == options
                                    
    finder = Redistat::Finder.scope("PageViews").label("Label").from(two_hours_ago).till(one_hour_ago).depth(:hour).interval(:hour)
    finder.options.should == options
    
    finder = Redistat::Finder.label("Label").from(two_hours_ago).till(one_hour_ago).depth(:hour).interval(:hour).scope("PageViews")
    finder.options.should == options
    
    finder = Redistat::Finder.from(two_hours_ago).till(one_hour_ago).depth(:hour).interval(:hour).scope("PageViews").label("Label")
    finder.options.should == options
    
    finder = Redistat::Finder.till(one_hour_ago).depth(:hour).interval(:hour).scope("PageViews").label("Label").from(two_hours_ago)
    finder.options.should == options
    
    finder = Redistat::Finder.depth(:hour).interval(:hour).scope("PageViews").label("Label").from(two_hours_ago).till(one_hour_ago)
    finder.options.should == options
    
    finder = Redistat::Finder.interval(:hour).scope("PageViews").label("Label").from(two_hours_ago).till(one_hour_ago).depth(:hour)
    finder.options.should == options
    
  end
  
  it "should fetch stats properly" do
    key = Redistat::Key.new(@scope, @label, 2.hours.ago)
    Redistat::Summary.update(key, @stats, :hour)
    key = Redistat::Key.new(@scope, @label, 1.hours.ago)
    Redistat::Summary.update(key, @stats, :hour)
    key = Redistat::Key.new(@scope, @label, 24.minutes.ago)
    Redistat::Summary.update(key, @stats, :hour)
    
    three_hours_ago = 3.hours.ago
    two_hours_from_now = 2.hours.from_now
    depth = :hour
    
    stats = Redistat::Finder.find({:from => three_hours_ago, :till => two_hours_from_now, :scope => @scope, :label => @label, :depth => depth})
    stats.should == { "views" => 9, "visitors" => 6 }
    stats.date.to_s.should == three_hours_ago.to_rs.to_s(depth)
    stats.till.to_s.should == two_hours_from_now.to_rs.to_s(depth)
  end
  
  it "should return empty hash when attempting to fetch non-existent results" do
    stats = Redistat::Finder.find({:from => 3.hours.ago, :till => 2.hours.from_now, :scope => @scope, :label => @label, :depth => :hour})
    stats.should == {}
  end
  
  it "should fetch data per unit when interval option is specified" do
    
  end
  
end









