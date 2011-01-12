module Redistat
  class Date
    
    attr_accessor :year
    attr_accessor :month
    attr_accessor :day
    attr_accessor :hour
    attr_accessor :min
    attr_accessor :sec
    attr_accessor :usec
    attr_accessor :depth
    
    DEPTHS = [:year, :month, :day, :hour, :min, :sec, :usec]
    
    def initialize(input, depth = nil)
      @depth = depth
      if input.is_a?(::Time)
        from_time(input)
      elsif input.is_a?(::Date)
        from_date(input)
      elsif input.is_a?(::String)
        from_string(input)
      elsif input.is_a?(::Fixnum)
        from_integer(input)
      elsif input.is_a?(::Bignum)
        from_integer(input)
      end
    end
    
    def to_t
      ::Time.local(@year, @month, @day, @hour, @min, @sec, @usec)
    end
    alias :to_time :to_t
    
    def to_d
      ::Date.civil(@year, @month, @day)
    end
    alias :to_date :to_d

    def to_i
      to_time.to_i
    end
    alias :to_integer :to_i
    
    def to_s(depth = nil)
      depth ||= @depth ||= :sec
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
    alias :to_string :to_s
    
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
      input += "19700101000000"[input.size..-1] if input =~ /^\d\d\d[\d]+$/i
      from_time(::Time.parse(input))
    end
    
  end
end
