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
    @two_hours_ago = 2.hours.ago
    @one_hour_ago = 1.hour.ago
  end
  
  it "should initialize properly" do
    options = {:scope => "PageViews", :label => "Label", :from => @two_hours_ago, :till => @one_hour_ago, :depth => :hour, :interval => :hour}
    
    finder = Redistat::Finder.new
    finder.send(:set_options, options)
    finder.options[:scope].should be_a(Redistat::Scope)
    finder.options[:scope].to_s.should == options[:scope]
    finder.options[:label].should be_a(Redistat::Label)
    finder.options[:label].to_s.should == options[:label]
    finder.options.should == options.merge(:scope => finder.options[:scope], :label => finder.options[:label])
    
    finder = Redistat::Finder.dates(@two_hours_ago, @one_hour_ago)
    finder.options[:from].should == @two_hours_ago
    finder.options[:till].should == @one_hour_ago
    
    finder = Redistat::Finder.scope("hello")
    finder.options[:scope].to_s.should == "hello"
    
    finder = Redistat::Finder.label("hello")
    finder.options[:label].to_s.should == "hello"
    
    finder = Redistat::Finder.from(@two_hours_ago)
    finder.options[:from].should == @two_hours_ago
    
    finder = Redistat::Finder.till(@one_hour_ago)
    finder.options[:till].should == @one_hour_ago
    
    finder = Redistat::Finder.depth(:hour)
    finder.options[:depth].should == :hour
    
    finder = Redistat::Finder.interval(true)
    finder.options[:interval].should be_true
    
    finder = Redistat::Finder.interval(false)
    finder.options[:interval].should be_false
    
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
  
  describe "Grouping" do
    before(:each) do
      @options = {:scope => "PageViews", :label => "message/public", :from => @two_hours_ago, :till => @one_hour_ago, :depth => :hour, :interval => :hour}
      @finder = Redistat::Finder.new(@options)
    end
    
    it "should return parent finder" do
      @finder.instance_variable_get("@parent").should be_nil
      @finder.parent.should be_a(Redistat::Finder)
      @finder.instance_variable_get("@parent").should_not be_nil
      @finder.parent.options[:label].to_s.should == 'message'
      @finder.label('message')
      @finder.instance_variable_get("@parent").should be_nil
      @finder.parent.should_not be_nil
      @finder.parent.options[:label].should be_nil
      @finder.parent.parent.should be_nil
    end
    
    it "should find children" do
      Redistat::Key.new("PageViews", "message/public/die").update_index
      Redistat::Key.new("PageViews", "message/public/live").update_index
      Redistat::Key.new("PageViews", "message/public/fester").update_index
      members = db.smembers("#{@scope}#{Redistat::LABEL_INDEX}message/public") # checking 'message/public'
      @finder.children.first.should be_a(Redistat::Finder)
      subs = @finder.children.map { |f| f.options[:label].me }
      subs.should have(3).items
      subs.should include('die')
      subs.should include('live')
      subs.should include('fester')
    end
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
    
  end # "Lazy-Loading"
  
  
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
