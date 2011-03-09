module Redistat
  class Key
    
    attr_accessor :date
    attr_accessor :options
    
    def initialize(scope, label_name = nil, time_stamp = nil, options = {})
      @options = default_options.merge(options || {})
      self.scope = scope
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
    
    def label=(input)
      @label = (input.instance_of?(Redistat::Label)) ? input : Label.create(input, @options)
    end
    
    def label_hash
      @label.hash
    end
    
    def label_groups
      @label.groups
    end
    
    def scope
      @scope.to_s
    end
    
    def scope=(input)
      @scope = (input.instance_of?(Redistat::Scope)) ? input : Scope.new(input)
    end
    
    def groups
      @groups ||= label_groups.map do |label_name|
        self.class.new(@scope, label_name, self.date, @options)
      end
    end
    
    def parent_group
      @label.parent_group
    end
    
    def update_label_index
      @label.update_index
    end
    
    def to_s(depth = nil)
      depth ||= @options[:depth]
      key = self.prefix
      key << @date.to_s(depth)
      key
    end
    
  end
end