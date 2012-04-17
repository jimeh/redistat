module Redistat
  module DateHelper
    def to_redistat(depth = nil)
      Redistat::Date.new(self, depth)
    end
    alias :to_rs :to_redistat
  end
end
