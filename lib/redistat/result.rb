module Redistat
  class Result < ::Hash
    
    attr_accessor :date
    attr_accessor :till
    
    def set_or_incr(key, value)
      self[key] = 0 if !self.has_key?(key)
      self[key] += value
      self
    end
    
  end
end