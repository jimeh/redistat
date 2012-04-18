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
    db.hget(Redistat::KEY_LABELS, label.hash).should == @name

    name = "contact_us"
    label = Redistat::Label.create(name, {:hashed_label => true})
    label.saved?.should be_true
    db.hget(Redistat::KEY_LABELS, label.hash).should == name
  end

  it "should join labels" do
    include Redistat
    label = Label.join('email', 'message', 'public')
    label.should be_a(Label)
    label.to_s.should == 'email/message/public'
    label = Label.join(Label.new('email'), Label.new('message'), Label.new('public'))
    label.should be_a(Label)
    label.to_s.should == 'email/message/public'
    label = Label.join('email', '', 'message', nil, 'public')
    label.should be_a(Label)
    label.to_s.should == 'email/message/public'
  end

  it "should allow you to use a different group separator" do
    include Redistat
    Redistat.group_separator = '|'
    label = Label.join('email', 'message', 'public')
    label.should be_a(Label)
    label.to_s.should == 'email|message|public'
    label = Label.join(Label.new('email'), Label.new('message'), Label.new('public'))
    label.should be_a(Label)
    label.to_s.should == 'email|message|public'
    label = Label.join('email', '', 'message', nil, 'public')
    label.should be_a(Label)
    label.to_s.should == 'email|message|public'
    Redistat.group_separator = Redistat::GROUP_SEPARATOR
  end

  describe "Grouping" do
    before(:each) do
      @name = "message/public/offensive"
      @label = Redistat::Label.new(@name)
    end

    it "should know it's parent label group" do
      @label.parent.to_s.should == 'message/public'
      Redistat::Label.new('hello').parent.should be_nil
    end

    it "should separate label names into groups" do
      @label.name.should == @name
      @label.groups.map { |l| l.to_s }.should == [ "message/public/offensive",
                                                   "message/public",
                                                   "message" ]

      @name = "/message/public/"
      @label = Redistat::Label.new(@name)
      @label.name.should == @name
      @label.groups.map { |l| l.to_s }.should == [ "message/public",
                                                   "message" ]

      @name = "message"
      @label = Redistat::Label.new(@name)
      @label.name.should == @name
      @label.groups.map { |l| l.to_s }.should == [ "message" ]
    end
  end

end
