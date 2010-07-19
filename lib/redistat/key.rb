module Redistat
  class Key
    
    attr_accessor :scope
    attr_accessor :date
    attr_accessor :options
    
    def initialize(scope, label = nil, date = nil, options = {})
      @scope = scope
      self.label = label if !label.nil?
      self.date = date ||= Time.now
      self.options = options
    end
    
    def date=(input)
      @date = (input.instance_of?(Redistat::Date)) ? input : Date.new(input) # Redistat::Date, not ::Date
    end
    
    def label
      @label.name
    end
    
    def label_hash
      @label.hash
    end
    
    def label=(input)
      @label = (input.instance_of?(Redistat::Label)) ? input : Label.create(input)
    end
    
    def to_s(depth = nil)
      depth ||= @options[:depth] if !@options[:depth].nil?
      key = "#{@scope}"
      key << "/" + ((@options[:label_hash].nil? || @options[:label_hash] == true) ? @label.hash : @label.name) if !label.nil?
      key << ":#{@date.to_s(depth)}"
    end
    
  end
end