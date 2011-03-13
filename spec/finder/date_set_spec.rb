require "spec_helper"

describe Redistat::Finder::DateSet do
  
  before(:all) do
    @finder = Redistat::Finder::DateSet.new
  end
  
  it "should initialize properly" do
    t_start = Time.utc(2010, 8, 28, 22, 54, 57)
    t_end = Time.utc(2013, 12, 4, 22, 52, 3)
    result = Redistat::Finder::DateSet.new(t_start, t_end)
    result.should == [
      { :add => ["2010082822", "2010082823"],             :rem => []             },
      { :add => ["20131204"],                             :rem => ["2013120423"] },
      { :add => ["20100829", "20100830", "20100831"],     :rem => []             },
      { :add => ["20131201", "20131202", "20131203"],     :rem => []             },
      { :add => ["201009", "201010", "201011", "201012"], :rem => []             },
      { :add => ["2013"],                                 :rem => ["201312"]     },
      { :add => ["2011", "2012"],                         :rem => []             }
    ]
  end
  
  it "should find date sets by interval" do
    t_start = Time.utc(2010, 8, 28, 18, 54, 57)
    
    t_end = t_start + 4.hours
    result = Redistat::Finder::DateSet.new.find_date_sets(t_start, t_end, :hour, true)
    result[0][:add].should == ["2010082818", "2010082819", "2010082820", "2010082821", "2010082822"]
    result[0][:rem].should == []
    result.should == Redistat::Finder::DateSet.new(t_start, t_end, nil, :hour)
    
    t_end = t_start + 4.days
    result = Redistat::Finder::DateSet.new.find_date_sets(t_start, t_end, :day, true)
    result[0][:add].should == ["20100828", "20100829", "20100830", "20100831", "20100901"]
    result[0][:rem].should == []
    result.should == Redistat::Finder::DateSet.new(t_start, t_end, nil, :day)
  end
  
  it "should find start keys properly" do
    
    #
    # Simple fetching
    # Dates: 22:54, 26th August, 2010 --> 22:52, 14th December, 2010
    #
    
    t_start = Time.utc(2010, 8, 26, 22, 54, 57)
    t_end = Time.utc(2013, 12, 14, 22, 52, 3)
  
    result = @finder.send(:find_start_keys_for, :sec, t_start, t_end)
    result[:add].should == ["20100826225458", "20100826225459"]
    result[:rem].should == []
    
    result = @finder.send(:find_start_keys_for, :min, t_start, t_end)
    result[:add].should == ["201008262255", "201008262256", "201008262257", "201008262258", "201008262259"]
    result[:rem].should == []
    
    result = @finder.send(:find_start_keys_for, :hour, t_start, t_end)
    result[:add].should == ["2010082623"]
    result[:rem].should == []
    
    result = @finder.send(:find_start_keys_for, :day, t_start, t_end)
    result[:add].should == ["20100827", "20100828", "20100829", "20100830", "20100831"]
    result[:rem].should == []
    
    result = @finder.send(:find_start_keys_for, :month, t_start, t_end)
    result[:add].should == ["201009", "201010", "201011", "201012"]
    result[:rem].should == []
    
    result = @finder.send(:find_start_keys_for, :year, t_start, t_end)
    result[:add].should == ["2011", "2012"]
    result[:rem].should == []
    
    #
    # Reverse / Inteligent fetching
    # Dates: 5:06, 4th April, 2010 --> 22:52, 14th February, 2011
    #
    
    t_start = Time.utc(2010, 4, 4, 5, 6, 4)
    t_end = Time.utc(2011, 2, 14, 22, 52, 3)
  
    result = @finder.send(:find_start_keys_for, :sec, t_start, t_end)
    result[:add].should == ["201004040506"]
    result[:rem].should == ["20100404050600", "20100404050601", "20100404050602", "20100404050603", "20100404050604"]
    
    result = @finder.send(:find_start_keys_for, :min, t_start, t_end)
    result[:add].should == ["2010040405"]
    result[:rem].should == ["201004040500", "201004040501", "201004040502", "201004040503", "201004040504", "201004040505", "201004040506"]
    
    result = @finder.send(:find_start_keys_for, :hour, t_start, t_end)
    result[:add].should == ["20100404"]
    result[:rem].should == ["2010040400", "2010040401", "2010040402", "2010040403", "2010040404", "2010040405"]
    
    result = @finder.send(:find_start_keys_for, :day, t_start, t_end)
    result[:add].should == ["201004"]
    result[:rem].should == ["20100401", "20100402", "20100403", "20100404"]
    
    result = @finder.send(:find_start_keys_for, :month, t_start, t_end)
    result[:add].should == ["2010"]
    result[:rem].should == ["201001", "201002", "201003", "201004"]
    
    result = @finder.send(:find_start_keys_for, :year, t_start, t_end)
    result[:add].should == []
    result[:rem].should == []
    
  end
  
  it "should find end keys properly" do
    
    #
    # Simple fetching
    # Dates: 22:04, 26th December, 2007 --> 5:06, 7th May, 2010
    #
    
    t_start = Time.utc(2007, 12, 26, 22, 4, 4)
    t_end = Time.utc(2010, 5, 7, 5, 6, 3)
  
    result = @finder.send(:find_end_keys_for, :sec, t_start, t_end)
    result[:add].should == ["20100507050600", "20100507050601", "20100507050602"]
    result[:rem].should == []
    
    result = @finder.send(:find_end_keys_for, :min, t_start, t_end)
    result[:add].should == ["201005070500", "201005070501", "201005070502", "201005070503", "201005070504", "201005070505"]
    result[:rem].should == []
    
    result = @finder.send(:find_end_keys_for, :hour, t_start, t_end)
    result[:add].should == ["2010050700", "2010050701", "2010050702", "2010050703", "2010050704"]
    result[:rem].should == []
    
    result = @finder.send(:find_end_keys_for, :day, t_start, t_end)
    result[:add].should == ["20100501", "20100502", "20100503", "20100504", "20100505", "20100506"]
    result[:rem].should == []
    
    result = @finder.send(:find_end_keys_for, :month, t_start, t_end)
    result[:add].should == ["201001", "201002", "201003", "201004"]
    result[:rem].should == []
    
    result = @finder.send(:find_end_keys_for, :year, t_start, t_end)
    result[:add].should == []
    result[:rem].should == []
    
    #
    # Reverse / Inteligent fetching
    # Dates: 22:04, 26th December, 2009 --> 22:56, 27th October, 2010
    #
    
    t_start = Time.utc(2009, 12, 26, 22, 4, 4)
    t_end = Time.utc(2010, 10, 27, 22, 56, 57)
  
    result = @finder.send(:find_end_keys_for, :sec, t_start, t_end)
    result[:add].should == ["201010272256"]
    result[:rem].should == ["20101027225657", "20101027225658", "20101027225659"]
    
    result = @finder.send(:find_end_keys_for, :min, t_start, t_end)
    result[:add].should == ["2010102722"]
    result[:rem].should == ["201010272256", "201010272257", "201010272258", "201010272259"]
    
    result = @finder.send(:find_end_keys_for, :hour, t_start, t_end)
    result[:add].should == ["20101027"]
    result[:rem].should == ["2010102722", "2010102723"]
    
    result = @finder.send(:find_end_keys_for, :day, t_start, t_end)
    result[:add].should == ["201010"]
    result[:rem].should == ["20101027", "20101028", "20101029", "20101030", "20101031"]
    
    result = @finder.send(:find_end_keys_for, :month, t_start, t_end)
    result[:add].should == ["2010"]
    result[:rem].should == ["201010", "201011", "201012"]
    
    result = @finder.send(:find_end_keys_for, :year, t_start, t_end)
    result[:add].should == []
    result[:rem].should == []
    
  end
  
  it "should fetch start/end keys with limits" do
    
    #
    # Simple fetching with Limits
    #
    
    # seconds
    t_start = Time.utc(2010, 8, 26, 20, 54, 45)
    t_end = t_start + 4.seconds
    
    result = @finder.send(:find_start_keys_for, :sec, t_start, t_end)
    result[:add].should == ["20100826205446", "20100826205447", "20100826205448"]
    result[:rem].should == []
    
    result = @finder.send(:find_end_keys_for, :sec, t_start, t_end)
    result[:add].should == []
    result[:rem].should == []
    
    t_start = Time.utc(2010, 8, 26, 20, 54, 4)
    t_end = t_start + 4.seconds
    
    result = @finder.send(:find_start_keys_for, :sec, t_start, t_end)
    result[:add].should == ["20100826205405", "20100826205406", "20100826205407"]
    result[:rem].should == []
    
    result = @finder.send(:find_end_keys_for, :sec, t_start, t_end)
    result[:add].should == []
    result[:rem].should == []
    
    # minutes
    t_start = Time.utc(2010, 8, 26, 20, 54)
    t_end = t_start + 4.minutes
    
    result = @finder.send(:find_start_keys_for, :min, t_start, t_end)
    result[:add].should == ["201008262055", "201008262056", "201008262057"]
    result[:rem].should == []
    
    result = @finder.send(:find_end_keys_for, :min, t_start, t_end)
    result[:add].should == []
    result[:rem].should == []
    
    t_start = Time.utc(2010, 8, 26, 20, 4)
    t_end = t_start + 4.minutes
    
    result = @finder.send(:find_start_keys_for, :min, t_start, t_end)
    result[:add].should == ["201008262005", "201008262006", "201008262007"]
    result[:rem].should == []
    
    result = @finder.send(:find_end_keys_for, :min, t_start, t_end)
    result[:add].should == []
    result[:rem].should == []
    
    # hours
    t_start = Time.utc(2010, 8, 26, 20, 54)
    t_end = t_start + 2.hours
  
    result = @finder.send(:find_start_keys_for, :min, t_start, t_end)
    result[:add].should == ["201008262055", "201008262056", "201008262057", "201008262058", "201008262059"]
    result[:rem].should == []
    
    result = @finder.send(:find_start_keys_for, :hour, t_start, t_end)
    result[:add].should == ["2010082621"]
    result[:rem].should == []
    
    result = @finder.send(:find_end_keys_for, :hour, t_start, t_end)
    result[:add].should == []
    result[:rem].should == []
    
    result = @finder.send(:find_end_keys_for, :min, t_start, t_end)
    result[:add].should == ["2010082622"]
    result[:rem].should == ["201008262254", "201008262255", "201008262256", "201008262257", "201008262258", "201008262259"]
    
    t_start = Time.utc(2010, 8, 26, 4, 54)
    t_end = t_start + 5.hours
    
    result = @finder.send(:find_start_keys_for, :min, t_start, t_end)
    result[:add].should == ["201008260455", "201008260456", "201008260457", "201008260458", "201008260459"]
    result[:rem].should == []
    
    result = @finder.send(:find_start_keys_for, :hour, t_start, t_end)
    result[:add].should == ["2010082605", "2010082606", "2010082607", "2010082608"]
    result[:rem].should == []
    
    result = @finder.send(:find_end_keys_for, :hour, t_start, t_end)
    result[:add].should == []
    result[:rem].should == []
    
    result = @finder.send(:find_end_keys_for, :min, t_start, t_end)
    result[:add].should == ["2010082609"]
    result[:rem].should == ["201008260954", "201008260955", "201008260956", "201008260957", "201008260958", "201008260959"]
    
    # days
    t_start = Time.utc(2010, 8, 26, 20, 54)
    t_end = t_start + 2.day
    
    result = @finder.send(:find_start_keys_for, :min, t_start, t_end)
    result[:add].should == ["201008262055", "201008262056", "201008262057", "201008262058", "201008262059"]
    result[:rem].should == []
    
    result = @finder.send(:find_start_keys_for, :hour, t_start, t_end)
    result[:add].should == ["2010082621", "2010082622", "2010082623"]
    result[:rem].should == []
    
    result = @finder.send(:find_start_keys_for, :day, t_start, t_end)
    result[:add].should == ["20100827"]
    result[:rem].should == []
    
    result = @finder.send(:find_end_keys_for, :day, t_start, t_end)
    result[:add].should == []
    result[:rem].should == []
    
    result = @finder.send(:find_end_keys_for, :hour, t_start, t_end)
    result[:add].should == ["20100828"]
    result[:rem].should == ["2010082820", "2010082821", "2010082822", "2010082823"]
    
    result = @finder.send(:find_end_keys_for, :min, t_start, t_end)
    result[:add].should == ["2010082820"]
    result[:rem].should == ["201008282054", "201008282055", "201008282056", "201008282057", "201008282058", "201008282059"]
    
    t_start = Time.utc(2010, 8, 6, 20, 54)
    t_end = t_start + 2.day
    
    result = @finder.send(:find_start_keys_for, :min, t_start, t_end)
    result[:add].should == ["201008062055", "201008062056", "201008062057", "201008062058", "201008062059"]
    result[:rem].should == []
    
    result = @finder.send(:find_start_keys_for, :hour, t_start, t_end)
    result[:add].should == ["2010080621", "2010080622", "2010080623"]
    result[:rem].should == []
    
    result = @finder.send(:find_start_keys_for, :day, t_start, t_end)
    result[:add].should == ["20100807"]
    result[:rem].should == []
    
    result = @finder.send(:find_end_keys_for, :day, t_start, t_end)
    result[:add].should == []
    result[:rem].should == []
    
    result = @finder.send(:find_end_keys_for, :hour, t_start, t_end)
    result[:add].should == ["20100808"]
    result[:rem].should == ["2010080820", "2010080821", "2010080822", "2010080823"]
    
    result = @finder.send(:find_end_keys_for, :min, t_start, t_end)
    result[:add].should == ["2010080820"]
    result[:rem].should == ["201008082054", "201008082055", "201008082056", "201008082057", "201008082058", "201008082059"]
    
    # months
    t_start = Time.utc(2010, 8, 26, 20, 54)
    t_end = t_start + 3.months
    
    result = @finder.send(:find_start_keys_for, :min, t_start, t_end)
    result[:add].should == ["201008262055", "201008262056", "201008262057", "201008262058", "201008262059"]
    result[:rem].should == []
    
    result = @finder.send(:find_start_keys_for, :hour, t_start, t_end)
    result[:add].should == ["2010082621", "2010082622", "2010082623"]
    result[:rem].should == []
        
    result = @finder.send(:find_start_keys_for, :day, t_start, t_end)
    result[:add].should == ["20100827", "20100828", "20100829", "20100830", "20100831"]
    result[:rem].should == []
    
    result = @finder.send(:find_start_keys_for, :month, t_start, t_end)
    result[:add].should == ["201009", "201010"]
    result[:rem].should == []
    
    result = @finder.send(:find_end_keys_for, :month, t_start, t_end)
    result[:add].should == []
    result[:rem].should == []
    
    result = @finder.send(:find_end_keys_for, :day, t_start, t_end)
    result[:add].should == ["201011"]
    result[:rem].should == ["20101126", "20101127", "20101128", "20101129", "20101130"]
    
    result = @finder.send(:find_end_keys_for, :hour, t_start, t_end)
    result[:add].should == ["20101126"]
    result[:rem].should == ["2010112620", "2010112621", "2010112622", "2010112623"]
    
    result = @finder.send(:find_end_keys_for, :min, t_start, t_end)
    result[:add].should == ["2010112620"]
    result[:rem].should == ["201011262054", "201011262055", "201011262056", "201011262057", "201011262058", "201011262059"]
    
    t_start = Time.utc(2010, 4, 26, 20, 54)
    t_end = t_start + 3.months
    
    result = @finder.send(:find_start_keys_for, :min, t_start, t_end)
    result[:add].should == ["201004262055", "201004262056", "201004262057", "201004262058", "201004262059"]
    result[:rem].should == []
        
    result = @finder.send(:find_start_keys_for, :hour, t_start, t_end)
    result[:add].should == ["2010042621", "2010042622", "2010042623"]
    result[:rem].should == []
        
    result = @finder.send(:find_start_keys_for, :day, t_start, t_end)
    result[:add].should == ["20100427", "20100428", "20100429", "20100430"]
    result[:rem].should == []
    
    result = @finder.send(:find_start_keys_for, :month, t_start, t_end)
    result[:add].should == ["201005", "201006"]
    result[:rem].should == []
    
    result = @finder.send(:find_end_keys_for, :month, t_start, t_end)
    result[:add].should == []
    result[:rem].should == []
    
    result = @finder.send(:find_end_keys_for, :day, t_start, t_end)
    result[:add].should == ["201007"]
    result[:rem].should == ["20100726", "20100727", "20100728", "20100729", "20100730", "20100731"]
    
    result = @finder.send(:find_end_keys_for, :hour, t_start, t_end)
    result[:add].should == ["20100726"]
    result[:rem].should == ["2010072620", "2010072621", "2010072622", "2010072623"]
    
    result = @finder.send(:find_end_keys_for, :min, t_start, t_end)
    result[:add].should == ["2010072620"]
    result[:rem].should == ["201007262054", "201007262055", "201007262056", "201007262057", "201007262058", "201007262059"]
    
  end
  
  it "should find inclusive keys on lowest depth" do
    
    #
    # Simple start fetching
    # Dates: 22:54, 26th August, 2010 --> 22:52, 14th December, 2010
    #
    
    t_start = Time.utc(2010, 8, 26, 22, 54, 57)
    t_end = Time.utc(2013, 12, 14, 22, 52, 3)
  
    result = @finder.send(:find_start_keys_for, :sec, t_start, t_end, true)
    result[:add].should == ["20100826225457", "20100826225458", "20100826225459"]
    result[:rem].should == []
    
    result = @finder.send(:find_start_keys_for, :min, t_start, t_end, true)
    result[:add].should == ["201008262254", "201008262255", "201008262256", "201008262257", "201008262258", "201008262259"]
    result[:rem].should == []
    
    result = @finder.send(:find_start_keys_for, :hour, t_start, t_end, true)
    result[:add].should == ["2010082622", "2010082623"]
    result[:rem].should == []
    
    result = @finder.send(:find_start_keys_for, :day, t_start, t_end, true)
    result[:add].should == ["20100826", "20100827", "20100828", "20100829", "20100830", "20100831"]
    result[:rem].should == []
    
    result = @finder.send(:find_start_keys_for, :month, t_start, t_end, true)
    result[:add].should == ["201008", "201009", "201010", "201011", "201012"]
    result[:rem].should == []
    
    result = @finder.send(:find_start_keys_for, :year, t_start, t_end, true)
    result[:add].should == ["2011", "2012", "2013"]
    result[:rem].should == []
    
    #
    # Reverse / Inteligent start fetching
    # Dates: 5:06, 4th April, 2010 --> 22:52, 14th February, 2011
    #
    
    t_start = Time.utc(2010, 4, 4, 5, 6, 4)
    t_end = Time.utc(2013, 2, 14, 22, 52, 3)
  
    result = @finder.send(:find_start_keys_for, :sec, t_start, t_end, true)
    result[:add].should == ["201004040506"]
    result[:rem].should == ["20100404050600", "20100404050601", "20100404050602", "20100404050603"]
    
    result = @finder.send(:find_start_keys_for, :min, t_start, t_end, true)
    result[:add].should == ["2010040405"]
    result[:rem].should == ["201004040500", "201004040501", "201004040502", "201004040503", "201004040504", "201004040505"]
    
    result = @finder.send(:find_start_keys_for, :hour, t_start, t_end, true)
    result[:add].should == ["20100404"]
    result[:rem].should == ["2010040400", "2010040401", "2010040402", "2010040403", "2010040404"]
    
    result = @finder.send(:find_start_keys_for, :day, t_start, t_end, true)
    result[:add].should == ["201004"]
    result[:rem].should == ["20100401", "20100402", "20100403"]
    
    result = @finder.send(:find_start_keys_for, :month, t_start, t_end, true)
    result[:add].should == ["2010"]
    result[:rem].should == ["201001", "201002", "201003"]
    
    result = @finder.send(:find_start_keys_for, :year, t_start, t_end, true)
    result[:add].should == ["2011", "2012", "2013"]
    result[:rem].should == []
    
    #
    # Simple fetching
    # Dates: 22:04, 26th December, 2007 --> 5:06, 7th May, 2010
    #
    
    t_start = Time.utc(2007, 12, 26, 22, 4, 4)
    t_end = Time.utc(2010, 5, 7, 5, 6, 3)
  
    result = @finder.send(:find_end_keys_for, :sec, t_start, t_end, true)
    result[:add].should == ["20100507050600", "20100507050601", "20100507050602", "20100507050603"]
    result[:rem].should == []
    
    result = @finder.send(:find_end_keys_for, :min, t_start, t_end, true)
    result[:add].should == ["201005070500", "201005070501", "201005070502", "201005070503", "201005070504", "201005070505", "201005070506"]
    result[:rem].should == []
    
    result = @finder.send(:find_end_keys_for, :hour, t_start, t_end, true)
    result[:add].should == ["2010050700", "2010050701", "2010050702", "2010050703", "2010050704", "2010050705"]
    result[:rem].should == []
    
    result = @finder.send(:find_end_keys_for, :day, t_start, t_end, true)
    result[:add].should == ["20100501", "20100502", "20100503", "20100504", "20100505", "20100506", "20100507"]
    result[:rem].should == []
    
    result = @finder.send(:find_end_keys_for, :month, t_start, t_end, true)
    result[:add].should == ["201001", "201002", "201003", "201004", "201005"]
    result[:rem].should == []
    
    result = @finder.send(:find_end_keys_for, :year, t_start, t_end, true)
    result[:add].should == ["2010"]
    result[:rem].should == []
    
    #
    # Reverse / Inteligent fetching
    # Dates: 22:04, 26th December, 2009 --> 22:56, 27th October, 2010
    #
    
    t_start = Time.utc(2009, 12, 26, 22, 4, 4)
    t_end = Time.utc(2010, 10, 27, 22, 56, 57)
  
    result = @finder.send(:find_end_keys_for, :sec, t_start, t_end, true)
    result[:add].should == ["201010272256"]
    result[:rem].should == ["20101027225658", "20101027225659"]
    
    result = @finder.send(:find_end_keys_for, :min, t_start, t_end, true)
    result[:add].should == ["2010102722"]
    result[:rem].should == ["201010272257", "201010272258", "201010272259"]
    
    result = @finder.send(:find_end_keys_for, :hour, t_start, t_end, true)
    result[:add].should == ["20101027"]
    result[:rem].should == ["2010102723"]
    
    result = @finder.send(:find_end_keys_for, :day, t_start, t_end, true)
    result[:add].should == ["201010"]
    result[:rem].should == ["20101028", "20101029", "20101030", "20101031"]
    
    result = @finder.send(:find_end_keys_for, :month, t_start, t_end, true)
    result[:add].should == ["2010"]
    result[:rem].should == ["201011", "201012"]
    
    result = @finder.send(:find_end_keys_for, :year, t_start, t_end, true)
    result[:add].should == ["2010"]
    result[:rem].should == []
    
  end
  
end