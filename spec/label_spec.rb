require "spec_helper"

describe Redistat::Label do
  include Redistat::Database
  
  before(:each) do
    db.flushdb
    @name = "about_us"
    @label = Redistat::Label.new(@name)
  end
  
  it "should initialize properly and SHA1 hash the label name" do
    @label.name.should == @name
    @label.hash.should == Digest::SHA1.hexdigest(@name)
  end
  
  it "should store a label hash lookup key" do
    label = Redistat::Label.new(@name, {:hashed_label => true}).save
    label.saved?.should be_true
    db.get("#{Redistat::KEY_LEBELS}#{label.hash}").should == @name
    
    name = "contact_us"
    label = Redistat::Label.create(name, {:hashed_label => true})
    label.saved?.should be_true
    db.get("#{Redistat::KEY_LEBELS}#{label.hash}").should == name
  end
  
end