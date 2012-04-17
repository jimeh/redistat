require "spec_helper"

describe Redistat::Options do

  before(:each) do
    @helper = OptionsHelper.new
    @helper.parse_options(:wtf => 'dude', :foo => 'booze')
  end

  it "should #parse_options" do
    @helper.options[:hello].should == 'world'
    @helper.options[:foo].should == 'booze'
    @helper.options[:wtf].should == 'dude'
    @helper.raw_options.should_not have_key(:hello)
  end

  it "should create option_accessors" do
    @helper.hello.should == 'world'
    @helper.hello('woooo')
    @helper.hello.should == 'woooo'
  end

end

class OptionsHelper
  include Redistat::Options

  option_accessor :hello

  def default_options
    { :hello => 'world',
      :foo => 'bar' }
  end


end
