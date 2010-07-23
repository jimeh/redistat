require "spec_helper"

describe Redistat::Label do
  
  before(:all) do
    db.flushdb
  end
  
  before(:each) do
    @name = "about_us"
    @label = Redistat::Label.new(@name)
  end
  
  it "should initialize properly and SHA1 hash the label name" do
    @label.name.should == @name
    @label.hash.should == Digest::SHA1.hexdigest(@name)
  end
  
  it "should store a label hash lookup key" do
    @label.save
    @label.saved?.should be_true
    db.get("#{Redistat::KEY_LEBELS}#{@label.hash}").should == @name
    
    @name = "contact_us"
    @label = Redistat::Label.create(@name)
    @label.saved?.should be_true
    db.get("#{Redistat::KEY_LEBELS}#{@label.hash}").should == @name
  end
  
  def db
    Redistat.redis
  end
  
end