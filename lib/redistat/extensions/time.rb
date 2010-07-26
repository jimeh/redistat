class Time
  include Redistat::DateHelper
  
  # %w[ round floor ceil ].each do |_method|
  #   define_method _method do |*args|
  #     seconds = args.first || 60
  #     Time.at((self.to_f / seconds).send(_method) * seconds)
  #   end
  # end
  
  DEPTHS = [:year, :month, :day, :hour, :min, :sec, :usec]
  
  def floor(unit, multiple = nil)
    multiple ||= 1
    new_time = []
    DEPTHS.each_with_index do |depth, i|
      index = DEPTHS.index(unit)
      if i < index
        new_time << self.send(depth)
      elsif i > index
        new_time << 0
      else
        new_time << self.send(depth)
      end
    end
    Time.utc(*new_time)
  end

end