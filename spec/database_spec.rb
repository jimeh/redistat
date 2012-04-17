require "spec_helper"

describe Redistat::Database do
  include Redistat::Database

  it "should make #db method available when included" do
    db.should == Redistat.redis
  end

end
