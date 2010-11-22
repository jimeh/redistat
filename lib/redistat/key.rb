module Redistat
  class Key
    
    attr_accessor :scope
    attr_accessor :date
    attr_accessor :options
    
    def initialize(scope, label_name = nil, time_stamp = nil, options = {})
      @options = default_options.merge(options || {})
      @scope = scope
      self.label = label_name if !label_name.nil?
      self.date = time_stamp ||= Time.now
    end
    
    def default_options
      { :depth => :hour, :hashed_label => false }
    end
    
    def prefix
      key = "#{@scope}"
      key << "/#{label}" if !label.nil?
      key << ":"
      key
    end
    
    def date=(input)
      @date = (input.instance_of?(Redistat::Date)) ? input : Date.new(input) # Redistat::Date, not ::Date
    end
    
    def depth
      @options[:depth]
    end
    
    def label
      @label.name
    end
    
    def label_hash
      @label.hash
    end
    
    def label=(input)
      @label = (input.instance_of?(Redistat::Label)) ? input : Label.create(input, @options)
    end
    
    def to_s(depth = nil)
      depth ||= @options[:depth]
      key = self.prefix
      key << @date.to_s(depth)
      key
    end
    
  end
end