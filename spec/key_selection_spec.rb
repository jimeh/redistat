require "spec_helper"

describe Redistat::KeySelection do
  include Redistat::Database
  
  it "should find date sets" do
    t_start = Time.utc(2010, 8, 28, 22, 54, 57)
    t_end = Time.utc(2013, 12, 4, 22, 52, 3)
    result = Redistat::KeySelection.new(t_start, t_end).sets
    result.should == [
      { :add => ["2010082822", "2010082823"],             :sub => []             },
      { :add => ["20131204"],                             :sub => ["2013120423"] },
      { :add => ["20100829", "20100830", "20100831"],     :sub => []             },
      { :add => ["20131201", "20131202", "20131203"],     :sub => []             },
      { :add => ["201009", "201010", "201011", "201012"], :sub => []             },
      { :add => ["2013"],                                 :sub => ["201312"]     },
      { :add => ["2011", "2012"],                         :sub => []             },
      { :add => [],                                       :sub => []             }
    ]
  end
  
  it "should find date sets by interval" do
    t_start = Time.utc(2010, 8, 28, 18, 54, 57)
    
    t_end = t_start + 4.hours
    result = Redistat::KeySelection.find_date_sets(t_start, t_end, :hour, true)
    result[0][:add].should == ["2010082818", "2010082819", "2010082820", "2010082821", "2010082822"]
    result[0][:sub].should == []
    
    t_end = t_start + 4.days
    result = Redistat::KeySelection.find_date_sets(t_start, t_end, :day, true)
    result[0][:add].should == ["20100828", "20100829", "20100830", "20100831", "20100901"]
    result[0][:sub].should == []
  end
  
  it "should find start keys properly" do
    
    #
    # Simple fetching
    # Dates: 22:54, 26th August, 2010 --> 22:52, 14th December, 2010
    #
    
    t_start = Time.utc(2010, 8, 26, 22, 54, 57)
    t_end = Time.utc(2013, 12, 14, 22, 52, 3)

    result = Redistat::KeySelection.send(:find_start_keys_for, :sec, t_start, t_end)
    result[:add].should == ["20100826225458", "20100826225459"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_start_keys_for, :min, t_start, t_end)
    result[:add].should == ["201008262255", "201008262256", "201008262257", "201008262258", "201008262259"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_start_keys_for, :hour, t_start, t_end)
    result[:add].should == ["2010082623"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_start_keys_for, :day, t_start, t_end)
    result[:add].should == ["20100827", "20100828", "20100829", "20100830", "20100831"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_start_keys_for, :month, t_start, t_end)
    result[:add].should == ["201009", "201010", "201011", "201012"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_start_keys_for, :year, t_start, t_end)
    result[:add].should == ["2011", "2012"]
    result[:sub].should == []
    
    #
    # Reverse / Inteligent fetching
    # Dates: 5:06, 4th April, 2010 --> 22:52, 14th February, 2011
    #
    
    t_start = Time.utc(2010, 4, 4, 5, 6, 4)
    t_end = Time.utc(2011, 2, 14, 22, 52, 3)

    result = Redistat::KeySelection.send(:find_start_keys_for, :sec, t_start, t_end)
    result[:add].should == ["201004040506"]
    result[:sub].should == ["20100404050600", "20100404050601", "20100404050602", "20100404050603", "20100404050604"]
    
    result = Redistat::KeySelection.send(:find_start_keys_for, :min, t_start, t_end)
    result[:add].should == ["2010040405"]
    result[:sub].should == ["201004040500", "201004040501", "201004040502", "201004040503", "201004040504", "201004040505", "201004040506"]
    
    result = Redistat::KeySelection.send(:find_start_keys_for, :hour, t_start, t_end)
    result[:add].should == ["20100404"]
    result[:sub].should == ["2010040400", "2010040401", "2010040402", "2010040403", "2010040404", "2010040405"]
    
    result = Redistat::KeySelection.send(:find_start_keys_for, :day, t_start, t_end)
    result[:add].should == ["201004"]
    result[:sub].should == ["20100401", "20100402", "20100403", "20100404"]
    
    result = Redistat::KeySelection.send(:find_start_keys_for, :month, t_start, t_end)
    result[:add].should == ["2010"]
    result[:sub].should == ["201001", "201002", "201003", "201004"]
    
    result = Redistat::KeySelection.send(:find_start_keys_for, :year, t_start, t_end)
    result[:add].should == []
    result[:sub].should == []
    
  end
  
  it "should find end keys properly" do
    
    #
    # Simple fetching
    # Dates: 22:04, 26th December, 2007 --> 5:06, 7th May, 2010
    #
    
    t_start = Time.utc(2007, 12, 26, 22, 4, 4)
    t_end = Time.utc(2010, 5, 7, 5, 6, 3)

    result = Redistat::KeySelection.send(:find_end_keys_for, :sec, t_start, t_end)
    result[:add].should == ["20100507050600", "20100507050601", "20100507050602"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :min, t_start, t_end)
    result[:add].should == ["201005070500", "201005070501", "201005070502", "201005070503", "201005070504", "201005070505"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :hour, t_start, t_end)
    result[:add].should == ["2010050700", "2010050701", "2010050702", "2010050703", "2010050704"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :day, t_start, t_end)
    result[:add].should == ["20100501", "20100502", "20100503", "20100504", "20100505", "20100506"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :month, t_start, t_end)
    result[:add].should == ["201001", "201002", "201003", "201004"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :year, t_start, t_end)
    result[:add].should == []
    result[:sub].should == []
    
    #
    # Reverse / Inteligent fetching
    # Dates: 22:04, 26th December, 2009 --> 22:56, 27th October, 2010
    #
    
    t_start = Time.utc(2009, 12, 26, 22, 4, 4)
    t_end = Time.utc(2010, 10, 27, 22, 56, 57)

    result = Redistat::KeySelection.send(:find_end_keys_for, :sec, t_start, t_end)
    result[:add].should == ["201010272256"]
    result[:sub].should == ["20101027225657", "20101027225658", "20101027225659"]
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :min, t_start, t_end)
    result[:add].should == ["2010102722"]
    result[:sub].should == ["201010272256", "201010272257", "201010272258", "201010272259"]
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :hour, t_start, t_end)
    result[:add].should == ["20101027"]
    result[:sub].should == ["2010102722", "2010102723"]
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :day, t_start, t_end)
    result[:add].should == ["201010"]
    result[:sub].should == ["20101027", "20101028", "20101029", "20101030", "20101031"]
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :month, t_start, t_end)
    result[:add].should == ["2010"]
    result[:sub].should == ["201010", "201011", "201012"]
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :year, t_start, t_end)
    result[:add].should == []
    result[:sub].should == []
    
  end
  
  it "should fetch start/end keys with limits" do
    
    #
    # Simple fetching with Limits
    #
    
    t_start = Time.utc(2010, 8, 26, 20, 54)
    
    # seconds
    t_end = t_start + 4.seconds
    
    result = Redistat::KeySelection.send(:find_start_keys_for, :sec, t_start, t_end)
    result[:add].should == ["20100826205401", "20100826205402", "20100826205403"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :sec, t_start, t_end)
    result[:add].should == ["20100826205401", "20100826205402", "20100826205403"]
    result[:sub].should == []
    
    # minutes
    t_end = t_start + 4.minutes
    
    result = Redistat::KeySelection.send(:find_start_keys_for, :min, t_start, t_end)
    result[:add].should == ["201008262055", "201008262056", "201008262057"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :min, t_start, t_end)
    result[:add].should == []
    result[:sub].should == []
    
    # hours
    t_end = t_start + 2.hours

    result = Redistat::KeySelection.send(:find_start_keys_for, :min, t_start, t_end)
    result[:add].should == ["201008262055", "201008262056", "201008262057", "201008262058", "201008262059"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_start_keys_for, :hour, t_start, t_end)
    result[:add].should == ["2010082621"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :hour, t_start, t_end)
    result[:add].should == []
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :min, t_start, t_end)
    result[:add].should == ["2010082622"]
    result[:sub].should == ["201008262254", "201008262255", "201008262256", "201008262257", "201008262258", "201008262259"]
    
    # days
    t_end = t_start + 2.day

    result = Redistat::KeySelection.send(:find_start_keys_for, :hour, t_start, t_end)
    result[:add].should == ["2010082621", "2010082622", "2010082623"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_start_keys_for, :day, t_start, t_end)
    result[:add].should == ["20100827"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :day, t_start, t_end)
    result[:add].should == []
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :hour, t_start, t_end)
    result[:add].should == ["20100828"]
    result[:sub].should == ["2010082820", "2010082821", "2010082822", "2010082823"]
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :min, t_start, t_end)
    result[:add].should == ["2010082820"]
    result[:sub].should == ["201008282054", "201008282055", "201008282056", "201008282057", "201008282058", "201008282059"]
    
    # months
    t_end = t_start + 3.months
    
    result = Redistat::KeySelection.send(:find_start_keys_for, :day, t_start, t_end)
    result[:add].should == ["20100827", "20100828", "20100829", "20100830", "20100831"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_start_keys_for, :month, t_start, t_end)
    result[:add].should == ["201009", "201010"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :month, t_start, t_end)
    result[:add].should == []
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :day, t_start, t_end)
    result[:add].should == ["201011"]
    result[:sub].should == ["20101126", "20101127", "20101128", "20101129", "20101130"]
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :hour, t_start, t_end)
    result[:add].should == ["20101126"]
    result[:sub].should == ["2010112620", "2010112621", "2010112622", "2010112623"]
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :min, t_start, t_end)
    result[:add].should == ["2010112620"]
    result[:sub].should == ["201011262054", "201011262055", "201011262056", "201011262057", "201011262058", "201011262059"]
    
  end
  
  it "should find inclusive keys on lowest depth" do
    
    #
    # Simple start fetching
    # Dates: 22:54, 26th August, 2010 --> 22:52, 14th December, 2010
    #
    
    t_start = Time.utc(2010, 8, 26, 22, 54, 57)
    t_end = Time.utc(2013, 12, 14, 22, 52, 3)

    result = Redistat::KeySelection.send(:find_start_keys_for, :sec, t_start, t_end, true)
    result[:add].should == ["20100826225457", "20100826225458", "20100826225459"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_start_keys_for, :min, t_start, t_end, true)
    result[:add].should == ["201008262254", "201008262255", "201008262256", "201008262257", "201008262258", "201008262259"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_start_keys_for, :hour, t_start, t_end, true)
    result[:add].should == ["2010082622", "2010082623"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_start_keys_for, :day, t_start, t_end, true)
    result[:add].should == ["20100826", "20100827", "20100828", "20100829", "20100830", "20100831"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_start_keys_for, :month, t_start, t_end, true)
    result[:add].should == ["201008", "201009", "201010", "201011", "201012"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_start_keys_for, :year, t_start, t_end, true)
    result[:add].should == ["2011", "2012", "2013"]
    result[:sub].should == []
    
    #
    # Reverse / Inteligent start fetching
    # Dates: 5:06, 4th April, 2010 --> 22:52, 14th February, 2011
    #
    
    t_start = Time.utc(2010, 4, 4, 5, 6, 4)
    t_end = Time.utc(2013, 2, 14, 22, 52, 3)

    result = Redistat::KeySelection.send(:find_start_keys_for, :sec, t_start, t_end, true)
    result[:add].should == ["201004040506"]
    result[:sub].should == ["20100404050600", "20100404050601", "20100404050602", "20100404050603"]
    
    result = Redistat::KeySelection.send(:find_start_keys_for, :min, t_start, t_end, true)
    result[:add].should == ["2010040405"]
    result[:sub].should == ["201004040500", "201004040501", "201004040502", "201004040503", "201004040504", "201004040505"]
    
    result = Redistat::KeySelection.send(:find_start_keys_for, :hour, t_start, t_end, true)
    result[:add].should == ["20100404"]
    result[:sub].should == ["2010040400", "2010040401", "2010040402", "2010040403", "2010040404"]
    
    result = Redistat::KeySelection.send(:find_start_keys_for, :day, t_start, t_end, true)
    result[:add].should == ["201004"]
    result[:sub].should == ["20100401", "20100402", "20100403"]
    
    result = Redistat::KeySelection.send(:find_start_keys_for, :month, t_start, t_end, true)
    result[:add].should == ["2010"]
    result[:sub].should == ["201001", "201002", "201003"]
    
    result = Redistat::KeySelection.send(:find_start_keys_for, :year, t_start, t_end, true)
    result[:add].should == ["2011", "2012", "2013"]
    result[:sub].should == []
    
    #
    # Simple fetching
    # Dates: 22:04, 26th December, 2007 --> 5:06, 7th May, 2010
    #
    
    t_start = Time.utc(2007, 12, 26, 22, 4, 4)
    t_end = Time.utc(2010, 5, 7, 5, 6, 3)

    result = Redistat::KeySelection.send(:find_end_keys_for, :sec, t_start, t_end, true)
    result[:add].should == ["20100507050600", "20100507050601", "20100507050602", "20100507050603"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :min, t_start, t_end, true)
    result[:add].should == ["201005070500", "201005070501", "201005070502", "201005070503", "201005070504", "201005070505", "201005070506"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :hour, t_start, t_end, true)
    result[:add].should == ["2010050700", "2010050701", "2010050702", "2010050703", "2010050704", "2010050705"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :day, t_start, t_end, true)
    result[:add].should == ["20100501", "20100502", "20100503", "20100504", "20100505", "20100506", "20100507"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :month, t_start, t_end, true)
    result[:add].should == ["201001", "201002", "201003", "201004", "201005"]
    result[:sub].should == []
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :year, t_start, t_end, true)
    result[:add].should == ["2010"]
    result[:sub].should == []
    
    #
    # Reverse / Inteligent fetching
    # Dates: 22:04, 26th December, 2009 --> 22:56, 27th October, 2010
    #
    
    t_start = Time.utc(2009, 12, 26, 22, 4, 4)
    t_end = Time.utc(2010, 10, 27, 22, 56, 57)

    result = Redistat::KeySelection.send(:find_end_keys_for, :sec, t_start, t_end, true)
    result[:add].should == ["201010272256"]
    result[:sub].should == ["20101027225658", "20101027225659"]
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :min, t_start, t_end, true)
    result[:add].should == ["2010102722"]
    result[:sub].should == ["201010272257", "201010272258", "201010272259"]
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :hour, t_start, t_end, true)
    result[:add].should == ["20101027"]
    result[:sub].should == ["2010102723"]
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :day, t_start, t_end, true)
    result[:add].should == ["201010"]
    result[:sub].should == ["20101028", "20101029", "20101030", "20101031"]
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :month, t_start, t_end, true)
    result[:add].should == ["2010"]
    result[:sub].should == ["201011", "201012"]
    
    result = Redistat::KeySelection.send(:find_end_keys_for, :year, t_start, t_end, true)
    result[:add].should == ["2010"]
    result[:sub].should == []
    
  end
  
end























