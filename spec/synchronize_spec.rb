require "spec_helper"

describe Redistat::Synchronize do
  it { should respond_to(:monitor) }
  it { should respond_to(:thread_safe) }
  it { should respond_to(:thread_safe=) }
  
  describe "instanciated class with Redistat::Synchronize included" do
    subject { SynchronizeSpecHelper.new }
    it { should respond_to(:monitor) }
    it { should respond_to(:thread_safe) }
    it { should respond_to(:thread_safe=) }
    it { should respond_to(:synchronize) }
    
  end
  
  describe "#synchronize method" do
    
    before(:each) do
      Redistat::Synchronize.instance_variable_set("@thread_safe", nil)
      @obj = SynchronizeSpecHelper.new
    end
    
    it "should share single Monitor object across all objects" do
      @obj.monitor.should == Redistat::Synchronize.monitor
    end
    
    it "should share thread_safe option across all objects" do
      obj2 = SynchronizeSpecHelper.new
      Redistat::Synchronize.thread_safe.should be_false
      @obj.thread_safe.should be_false
      obj2.thread_safe.should be_false
      @obj.thread_safe = true
      Redistat::Synchronize.thread_safe.should be_true
      @obj.thread_safe.should be_true
      obj2.thread_safe.should be_true
    end
    
    it "should not synchronize when thread_safe is disabled" do
      # monitor receives :synchronize twice cause #thread_safe is _always_ synchronized
      Redistat::Synchronize.monitor.should_receive(:synchronize).twice
      @obj.thread_safe.should be_false # first #synchronize call
      @obj.synchronize { 'foo' } # one #synchronize call while checking #thread_safe
    end
    
    it "should synchronize when thread_safe is enabled" do
      Monitor.class_eval {
        # we're stubbing synchronize to ensure it's being called correctly, but still need it :P
        alias :real_synchronize :synchronize
      }
      Redistat::Synchronize.monitor.should_receive(:synchronize).with.exactly(4).times.and_return { |block|
        Redistat::Synchronize.monitor.real_synchronize(&block)
      }
      @obj.thread_safe.should be_false # first synchronize call
      Redistat::Synchronize.thread_safe = true # second synchronize call
      @obj.synchronize { 'foo' } # two synchronize calls, once while checking thread_safe, once to call black
    end
  end
  
end

class SynchronizeSpecHelper
  include Redistat::Synchronize
end
