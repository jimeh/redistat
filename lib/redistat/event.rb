module Redistat
  class Event
    
    attr_reader :key
    
    attr_accessor :stats
    attr_accessor :meta
    attr_accessor :options
    
    def initialize(scope, label = nil, date = nil, stats = {}, meta = {}, options = {})
      @options = default_options.merge(options)
      @scope = scope
      @key = Key.new(scope, label, date, @options)
      @stats = stats ||= {}
      @meta = meta ||= {}
    end
    
    def default_options
      { :depth => :hour,  }
    end
    
    def date
      @key.date
    end
    
    def date=(input)
      @key.date = input
    end
    
    alias :time :date
    alias :time= :date=
    
    def scope
      @key.scope
    end
    
    def scope=(input)
      @key.scope = input
    end
    
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