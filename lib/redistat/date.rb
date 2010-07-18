module Redistat
  class Date
    
    attr_accessor :year
    attr_accessor :month
    attr_accessor :day
    attr_accessor :hour
    attr_accessor :min
    attr_accessor :sec
    
    def initialize(input)
      if input.is_a?(::Time)
        from_time(input)
      elsif input.is_a?(::Date)
        from_date(input)
      elsif input.is_a?(::String)
        from_string(input)
      end
    end
    
    def from_time(input)
      [:year, :month, :day, :hour, :min, :sec].each do |k|
        self.send("#{k}=", input.send(k))
      end
    end
    
    def from_date(input)
      [:year, :month, :day].each do |k|
        self.send("#{k}=", input.send(k))
      end
    end
    
    def from_string(input)
      from_time(Time.parse(input))
    end
    
    def to_s(depth = :sec)
      output = ""
      [:year, :month, :day, :hour, :min, :sec].each_with_index do |current, i|
        break if self.send(current).nil?
        output << self.send(current).to_s.rjust((i <= 0) ? 4 : 2, '0')
        break if current == depth
      end
      output
    end
    
    alias :to_string :to_s
    
  end
end