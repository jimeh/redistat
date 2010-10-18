require "spec_helper"

describe Redistat::Scope do
  include Redistat::Database
  
  before(:all) do
    db.flushdb
  end
  
  before(:each) do
    @name = "PageViews"
    @scope = Redistat::Scope.new(@name)
  end
  
  it "should initialize properly" do
    @scope.to_s.should == @name
  end
  
  it "should increment next_id" do
    scope = Redistat::Scope.new("Visitors")
    @scope.next_id.should == 1
    scope.next_id.should == 1
    @scope.next_id.should == 2
    scope.next_id.should == 2
  end
  
end