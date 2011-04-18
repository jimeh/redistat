require "spec_helper"

describe Redistat::Buffer do
  
  before(:each) do
    @class  = Redistat::Buffer
    @buffer = Redistat::Buffer.instance
  end
  
  # let's cleanup after ourselves for the other specs
  after(:each) do
    @class.instance_variable_set("@instance", nil)
    @buffer.size = 0
  end
  
  it "should provide instance of itself" do
    @buffer.should be_a(@class)
  end
  
  it "should only buffer if buffer size setting is greater than 1" do
    @buffer.size.should == 0
    @buffer.send(:should_buffer?).should be_false
    @buffer.size = 1
    @buffer.size.should == 1
    @buffer.send(:should_buffer?).should be_false
    @buffer.size = 2
    @buffer.size.should == 2
    @buffer.send(:should_buffer?).should be_true
  end
  
  it "should only flush buffer if buffer size is greater than or equal to buffer size setting" do
    @buffer.size.should == 0
    @buffer.send(:queue).size.should == 0
    @buffer.send(:should_flush?).should be_false
    @buffer.send(:queue)[:hello] = 'world'
    @buffer.send(:should_flush?).should be_true
    @buffer.size = 5
    @buffer.send(:should_flush?).should be_false
    3.times { |i| @buffer.send(:queue)[i] = i.to_s }
    @buffer.send(:should_flush?).should be_false
    @buffer.send(:queue)[4] = '4'
    @buffer.send(:should_flush?).should be_true
  end
  
  it "should force flush queue irregardless of result of #should_flush? when #reset_queue is called with true" do
    @buffer.send(:queue)[:hello] = 'world'
    @buffer.send(:should_flush?).should be_true
    @buffer.size = 2
    @buffer.send(:should_flush?).should be_false
    @buffer.send(:reset_queue).should == {}
    @buffer.send(:reset_queue, true).should == {:hello => 'world'}
  end
  
  it "should #flush_data into Summary.update properly" do
    # the root level key value doesn't actually matter, but it's something like this...
    data = {'ScopeName/label/goes/here:2011:nil:true:true' => {
      :key => mock("Key"),
      :stats => {},
      :depth_limit => :year,
      :opts => {:heh => false}
    }}
    item = data.first[1]
    Redistat::Summary.should_receive(:update).with(item[:key], item[:stats], item[:depth_limit], item[:connection_ref])
    @buffer.send(:flush_data, data)
  end
  
  it "should build #buffer_key correctly" do
    key = mock('Key', :to_s => "Scope/label:2011")
    opts = {:enable_grouping => true, :label_indexing => false, :connection_ref => nil}
    @buffer.send(:buffer_key, key, opts).should == "#{key.to_s}::true:false"
    opts = {:enable_grouping => false, :label_indexing => true, :connection_ref => :omg}
    @buffer.send(:buffer_key, key, opts).should == "#{key.to_s}:omg:false:true"
  end
  
end
