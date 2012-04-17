require "spec_helper"

describe Redistat::Buffer do

  before(:each) do
    @class  = Redistat::Buffer
    @buffer = Redistat::Buffer.instance
    @key = mock('Key', :to_s => "Scope/label:2011")
    @stats = {:count => 1, :views => 3}
    @depth_limit = :hour
    @opts = {:enable_grouping => true}
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
    @buffer.send(:incr_count)
    @buffer.send(:should_flush?).should be_true
    @buffer.size = 5
    @buffer.send(:should_flush?).should be_false
    3.times { |i|
      @buffer.send(:queue)[i] = i.to_s
      @buffer.send(:incr_count)
    }
    @buffer.send(:should_flush?).should be_false
    @buffer.send(:queue)[4] = '4'
    @buffer.send(:incr_count)
    @buffer.send(:should_flush?).should be_true
  end

  it "should force flush queue irregardless of result of #should_flush? when #reset_queue is called with true" do
    @buffer.send(:queue)[:hello] = 'world'
    @buffer.send(:incr_count)
    @buffer.send(:should_flush?).should be_true
    @buffer.size = 2
    @buffer.send(:should_flush?).should be_false
    @buffer.send(:reset_queue).should == {}
    @buffer.instance_variable_get("@count").should == 1
    @buffer.send(:reset_queue, true).should == {:hello => 'world'}
    @buffer.instance_variable_get("@count").should == 0
  end

  it "should #flush_data into Summary.update properly" do
    # the root level key value doesn't actually matter, but it's something like this...
    data = {'ScopeName/label/goes/here:2011::true:true' => {
      :key => @key,
      :stats => @stats,
      :depth_limit => @depth_limit,
      :opts => @opts
    }}
    item = data.first[1]
    Redistat::Summary.should_receive(:update).with(@key, @stats, @depth_limit, @opts)
    @buffer.send(:flush_data, data)
  end

  it "should build #buffer_key correctly" do
    opts = {:enable_grouping => true, :label_indexing => false, :connection_ref => nil}
    @buffer.send(:buffer_key, @key, opts).should == "#{@key.to_s}::true:false"
    opts = {:enable_grouping => false, :label_indexing => true, :connection_ref => :omg}
    @buffer.send(:buffer_key, @key, opts).should == "#{@key.to_s}:omg:false:true"
  end

  describe "Buffering" do
    it "should store items on buffer queue" do
      @buffer.store(@key, @stats, @depth_limit, @opts).should be_false
      @buffer.size = 5
      @buffer.store(@key, @stats, @depth_limit, @opts).should be_true
      @buffer.send(:queue).should have(1).item
      @buffer.send(:queue)[@buffer.send(:queue).keys.first][:stats][:count].should == 1
      @buffer.send(:queue)[@buffer.send(:queue).keys.first][:stats][:views].should == 3
      @buffer.store(@key, @stats, @depth_limit, @opts).should be_true
      @buffer.send(:queue).should have(1).items
      @buffer.send(:queue)[@buffer.send(:queue).keys.first][:stats][:count].should == 2
      @buffer.send(:queue)[@buffer.send(:queue).keys.first][:stats][:views].should == 6
    end

    it "should flush buffer queue when size is reached" do
      key = mock('Key', :to_s => "Scope/labelx:2011")
      @buffer.size = 10
      Redistat::Summary.should_receive(:update).exactly(2).times.and_return do |k, stats, depth_limit, opts|
        depth_limit.should == @depth_limit
        opts.should == @opts
        if k == @key
          stats[:count].should == 6
          stats[:views].should == 18
        elsif k == key
          stats[:count].should == 4
          stats[:views].should == 12
        end
      end
      6.times { @buffer.store(@key, @stats, @depth_limit, @opts).should be_true }
      4.times { @buffer.store(key, @stats, @depth_limit, @opts).should be_true }
    end
  end

  describe "Thread-Safety" do
    it "should read/write to buffer queue in a thread-safe manner" do

      # Setting thread_safe to false only makes the spec fail with
      # JRuby. 1.8.x and 1.9.x both pass fine for some reason
      # regardless of what the thread_safe option is set to.
      Redistat.thread_safe = true

      key = mock('Key', :to_s => "Scope/labelx:2011")
      @buffer.size = 100

      Redistat::Summary.should_receive(:update).exactly(2).times.and_return do |k, stats, depth_limit, opts|
        depth_limit.should == @depth_limit
        opts.should == @opts
        if k == @key
          stats[:count].should == 60
          stats[:views].should == 180
        elsif k == key
          stats[:count].should == 40
          stats[:views].should == 120
        end
      end

      threads = []
      10.times do
        threads << Thread.new {
          6.times { @buffer.store(@key, @stats, @depth_limit, @opts).should be_true }
          4.times { @buffer.store(key, @stats, @depth_limit, @opts).should be_true }
        }
      end

      threads.each { |t| t.join }
    end

    it "should have specs that fail on 1.8.x/1.9.x when thread_safe is disabled"

  end

end
