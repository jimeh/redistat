module Redistat
  class Event
    
    attr_reader :scope
    attr_reader :label
    attr_reader :key
    attr_reader :options
    
    def initialize(scope, label = nil, data = {}, date = nil, options = {})
      @options = options
      @scope = scope
      @key = Key.new(scope, label, date, options)
      @label = @key.label
      #TODO ...intialize Redistat::Event
    end
    
    def date
      @key.date.to_date
    end
    
    def time
      @key.date.to_time
    end
    
    def save
      
    end
    
  end
end