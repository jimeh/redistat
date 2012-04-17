require "spec_helper"

describe "Thread-Safety" do
  include Redistat::Database

  before(:each) do
    db.flushdb
  end

  #TODO should have more comprehensive thread-safe tests

  it "should incr in multiple threads" do
    threads = []
    50.times do
      threads << Thread.new {
        db.incr("spec:incr")
      }
    end
    threads.each { |t| t.join }
    db.get("spec:incr").should == "50"
  end

  it "should store event in multiple threads" do
    class ThreadSafetySpec
      include Redistat::Model
    end
    threads = []
    50.times do
      threads << Thread.new {
        ThreadSafetySpec.store("spec:threadsafe", {:count => 1, :rand => rand(5)})
      }
    end
    threads.each { |t| t.join }
    result = ThreadSafetySpec.fetch("spec:threadsafe", 5.hours.ago, 5.hours.from_now)
    result.total[:count].should == 50
    result.total[:rand].should <= 250
  end

end
