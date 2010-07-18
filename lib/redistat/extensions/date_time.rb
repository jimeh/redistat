class Date
  def to_redistat(depth = nil)
    Redistat::Date.new(self).to_s(depth)
  end
end

class Time
  def to_redistat(depth = nil)
    Redistat::Date.new(self).to_s(depth)
  end
end