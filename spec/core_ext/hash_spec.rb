require "spec_helper"

describe Hash do
  
  it "should #set_or_incr values" do
    hash = {:count => 1}
    hash.set_or_incr(:sum, 3)
    hash.should == {:count => 1, :sum => 3}
    hash.set_or_incr(:count, 4)
    hash.should == {:count => 5, :sum => 3}
  end
  
  it "should #merge_and_incr hashes" do
    hash     = {:count => 1, :city => 'hell', :sum => 3, :name => 'john'}
    new_hash = {:count => 3, :city => 'slum', :views => 2}
    hash.merge_and_incr(new_hash)
    hash.should == {:count => 4, :sum => 3, :views => 2, :city => 'slum', :name => 'john'}
  end
  
end
