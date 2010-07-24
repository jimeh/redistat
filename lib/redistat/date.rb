module Redistat
  class Date
    
    attr_accessor :year
    attr_accessor :month
    attr_accessor :day
    attr_accessor :hour
    attr_accessor :min
    attr_accessor :sec
    attr_accessor :usec
    
    DEPTHS = [:year, :month, :day, :hour, :min, :sec, :usec]
    
    def initialize(input)
      if input.is_a?(::Time)
        from_time(input)
      elsif input.is_a?(::Date)
        from_date(input)
      elsif input.is_a?(::String)
        from_string(input)
      elsif input.is_a?(::Fixnum)
        from_integer(input)
      end
    end
    
    def to_time
      ::Time.local(@year, @month, @day, @hour, @min, @sec, @usec)
    end
    
    def to_date
      ::Date.civil(@year, @month, @day)
    end

    def to_integer
      to_time.to_i
    end
    
    def to_string(depth = nil)
      depth ||= :sec
      output = ""
      DEPTHS.each_with_index do |current, i|
        break if self.send(current).nil?
        if current != :usec
          output << self.send(current).to_s.rjust((i <= 0) ? 4 : 2, '0')
        else
          output << "." + self.send(current).to_s.rjust(6, '0')
        end
        break if current == depth
      end
      output
    end
    
    alias :to_t :to_time
    alias :to_d :to_date
    alias :to_i :to_integer
    alias :to_s :to_string
    
    
    private
    
    def from_time(input)
      DEPTHS.each do |k|
        send("#{k}=", input.send(k))
      end
    end

    def from_date(input)
      [:year, :month, :day].each do |k|
        send("#{k}=", input.send(k))
      end
      [:hour, :min, :sec, :usec].each do |k|
        send("#{k}=", 0)
      end
    end
    
    def from_integer(input)
      from_time(::Time.at(input))
    end
    
    def from_string(input)
      from_time(::Time.parse(input))
    end
    
  end
end


class Date
  def to_redistat
    Redistat::Date.new(self)
  end
  alias :to_rs :to_redistat
end

class Time
  def to_redistat
    Redistat::Date.new(self)
  end
  alias :to_rs :to_redistat
end

class Fixnum
  def to_redistat
    Redistat::Date.new(self)
  end
  alias :to_rs :to_redistat
end