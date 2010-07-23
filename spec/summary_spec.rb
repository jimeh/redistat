require "spec_helper"

describe Redistat::Label do
  
  before(:each) do
    db.flushdb
    @scope = "PageViews"
    @label = "about_us"
    @date = Time.now
    @key = Redistat::Key.new(@scope, @label, @date, {:depth => :day})
    @stats = {"views" => 3, "visitors" => 2}
  end
  
  it "should update a single summary properly" do
    Redistat::Summary.update(@key, @stats, :hour)
    summary = db.hgetall(@key.to_s(:hour))
    summary.should have(2).items
    summary["views"].should == "3"
    summary["visitors"].should == "2"
    
    Redistat::Summary.update(@key, @stats, :hour)
    summary = db.hgetall(@key.to_s(:hour))
    summary.should have(2).items
    summary["views"].should == "6"
    summary["visitors"].should == "4"
    
    Redistat::Summary.update(@key, {"views" => -4, "visitors" => -3}, :hour)
    summary = db.hgetall(@key.to_s(:hour))
    summary.should have(2).items
    summary["views"].should == "2"
    summary["visitors"].should == "1"
  end
  
  it "should update all summaries properly" do
    Redistat::Summary.update_all(@key, @stats, :sec)
    [:year, :month, :day, :hour, :min, :sec, :usec].each do |depth|
      summary = db.hgetall(@key.to_s(depth))
      if depth != :usec
        summary.should have(2).items
        summary["views"].should == "3"
        summary["visitors"].should == "2"
      else
        summary.should have(0).items
      end
    end
  end
  
  it "should fetch summary collections for date ranges"
  
  def db
    Redistat.redis
  end
  
end