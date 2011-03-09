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
    
    finder = Redistat::Finder.new
    finder.send(:set_options, options)
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
    first_stat, last_stat = create_example_stats
    
    stats = Redistat::Finder.find({:from => first_stat, :till => last_stat, :scope => @scope, :label => @label, :depth => :hour})
    stats.from.should  == first_stat
    stats.till.should  == last_stat
    stats.depth.should == :hour
    
    stats.total.should == { "views" => 12, "visitors" => 8 }
    stats.total.from.should == first_stat
    stats.total.till.should == last_stat
    stats.first.should == stats.total
  end
  
  it "should fetch data per unit when interval option is specified" do
    first_stat, last_stat = create_example_stats
    
    stats = Redistat::Finder.find(:from => first_stat, :till => last_stat, :scope => @scope, :label => @label, :depth => :hour, :interval => :hour)
    stats.from.should == first_stat
    stats.till.should == last_stat
    stats.total.should == { "views" => 12, "visitors" => 8 }
    stats[0].should == {}
    stats[0].date.should == Time.parse("2010-05-14 12:00")
    stats[1].should == {"visitors"=>"4", "views"=>"6"}
    stats[1].date.should == Time.parse("2010-05-14 13:00")
    stats[2].should == {"visitors"=>"2", "views"=>"3"}
    stats[2].date.should == Time.parse("2010-05-14 14:00")
    stats[3].should == {"visitors"=>"2", "views"=>"3"}
    stats[3].date.should == Time.parse("2010-05-14 15:00")
    stats[4].should == {}
    stats[4].date.should == Time.parse("2010-05-14 16:00")
  end
  
  it "should return empty hash when attempting to fetch non-existent results" do
    stats = Redistat::Finder.find({:from => 3.hours.ago, :till => 2.hours.from_now, :scope => @scope, :label => @label, :depth => :hour})
    stats.total.should == {}
  end
  
  it "should throw error on invalid options" do
    lambda { Redistat::Finder.find(:from => 3.hours.ago) }.should raise_error(Redistat::InvalidOptions)
  end
  
  describe "Lazy-Loading" do
    
    before(:each) do
      @first_stat, @last_stat = create_example_stats

      @finder = Redistat::Finder.new
      @finder.from(@first_stat).till(@last_stat).scope(@scope).label(@label).depth(:hour)
      
      @match = [{}, {"visitors"=>"4", "views"=>"6"},
                    {"visitors"=>"2", "views"=>"3"},
                    {"visitors"=>"2", "views"=>"3"}, {}]
    end
    
    it "should lazy-load" do

      @finder.instance_variable_get("@result").should be_nil
      stats = @finder.all
      @finder.instance_variable_get("@result").should_not be_nil
      
      stats.should == @finder.find # find method directly fetches results
      stats.total.should == @finder.total
      stats.total.should == { "views" => 12, "visitors" => 8 }
      stats.total.from.should == @first_stat
      stats.total.till.should == @last_stat
      stats.first.should == stats.total

      @finder.all.object_id.should == stats.object_id
      @finder.from(@first_stat + 2.hours)
      @finder.instance_variable_get("@result").should be_nil
      @finder.all.object_id.should_not == stats.object_id
      stats = @finder.all
      stats.total.should == { "views" => 6, "visitors" => 4 }
    end
    
    it "should handle #map" do
      @finder.interval(:hour)
      @finder.map { |r| r }.should == @match
    end
    
    it "should handle #each" do
      @finder.interval(:hour)
      
      res = []
      @finder.each { |r| res << r }
      res.should == @match
    end
    
    it "should handle #each_with_index" do
      @finder.interval(:hour)
      
      res = {}
      match = {}
      @finder.each_with_index { |r, i| res[i] = r }
      @match.each_with_index { |r, i| match[i] = r }
      res.should == match
    end
    
  end
  
  
  # helper methods
  
  def create_example_stats
    key = Redistat::Key.new(@scope, @label, (first = Time.parse("2010-05-14 13:43")))
    Redistat::Summary.update(key, @stats, :hour)
    key = Redistat::Key.new(@scope, @label, Time.parse("2010-05-14 13:53"))
    Redistat::Summary.update(key, @stats, :hour)
    key = Redistat::Key.new(@scope, @label, Time.parse("2010-05-14 14:52"))
    Redistat::Summary.update(key, @stats, :hour)
    key = Redistat::Key.new(@scope, @label, (last = Time.parse("2010-05-14 15:02")))
    Redistat::Summary.update(key, @stats, :hour)
    [first - 1.hour, last + 1.hour]
  end
  
end
