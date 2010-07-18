require "spec_helper"

describe Redistat::Event do
  
  before(:each) do
    @scope = "PageViews"
    @label = "/about/us"
    @label_hash = Digest::SHA1.hexdigest(@label)
    @now = Time.now
    @event = Redistat::Event.new(@scope, @label, {:views => 1}, @now, {:depth => :hour})
  end
  
  it "should initialize properly"
  
end