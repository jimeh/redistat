require "spec_helper"

describe Hash do
  
  it "should #set_or_incr values" do
    hash = {:count => 1}
    hash.set_or_incr(:sum, 3).should be_true
    hash.should == {:count => 1, :sum => 3}
    hash.set_or_incr(:count, 4).should be_true
    hash.should == {:count => 5, :sum => 3}
    hash.set_or_incr(:count, 'test').should be_false
    hash.set_or_incr(:view, 'test').should be_false
    hash.should == {:count => 5, :sum => 3}
    hash[:view] = 'test'
    hash.set_or_incr(:view, 3).should be_false
  end
  
  it "should #merge_and_incr hashes" do
    hash = { :count => 1, :city => 'hell', :sum => 3, :name => 'john' }
    
    new_hash = { :count => 3, :city => 'slum', :views => 2 }
    hash.clone.merge_and_incr(new_hash).should == { :count => 4, :city => 'slum', :views => 2,
                                                    :sum   => 3, :name => 'john' }
    
    new_hash = { :count => 'six', :city => 'slum', :views => 2, :time => 'late' }
    hash.clone.merge_and_incr(new_hash).should == { :count => 'six', :city => 'slum', :views => 2,
                                                    :sum   => 3, :name => 'john', :time => 'late' }
  end
  
end
