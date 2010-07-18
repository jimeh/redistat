module Redistat
  class Key
    
    attr_accessor :scope
    attr_accessor :label
    attr_accessor :date
    
    def initialize(scope, label = nil, date = nil, options = {})
      @scope = scope
      @label = Label.create(label) if !label.nil?
      @date = Date.new(date ||= Time.now) # Redistat::Date, not ::Date
      @options = options
    end
    
    #TODO figure out if direct access to the label object is desired or not
    # def label
    #   if !@label.nil?
    #     (@options[:hash_label] ||= true) ? @label.hash : @label.name
    #   end
    # end
    
    def to_s(depth = nil)
      depth ||= @options[:depth] if !@options[:depth].nil?
      key = "#{@scope}"
      key << "/#{@label.hash}" if !label.nil?
      key << ":#{@date.to_s(depth)}"
    end
    
  end
end