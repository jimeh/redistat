module Redistat
  class Event
    
    attr_reader :scope
    attr_reader :key
    
    attr_accessor :data
    attr_accessor :options
    
    def initialize(scope, label = nil, data = {}, date = nil, options = {})
      @options = options
      @scope = scope
      @key = Key.new(scope, label, date, options)
      #TODO ...intialize Redistat::Event
    end
    
    def date
      @key.date.to_time
    end
    
    def date=(input)
      @key.date = input
    end
    
    alias :time :date
    alias :time= :date=
    
    def label
      @key.label
    end
    
    def label_hash
      @key.label_hash
    end
    
    def label=(input)
      @key.label = input
    end
    
    
    def save
      
    end
    
  end
end