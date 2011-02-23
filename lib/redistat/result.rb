module Redistat
  class Result < HashWithIndifferentAccess
    
    attr_accessor :from
    attr_accessor :till
    
    alias :date :from
    alias :date= :from=
    
    def initialize(options = {})
      @from = options[:from] ||= nil
      @till = options[:till] ||= nil
    end
    
    
    def set_or_incr(key, value)
      self[key] = 0 if !self.has_key?(key)
      self[key] += value
      self
    end
    
  end
end