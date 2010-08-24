require "spec_helper"

describe Redistat::Finder do
  
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
  
end