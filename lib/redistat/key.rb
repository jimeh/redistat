module Redistat
  class Key
    include Database
    include Options
    
    def default_options
      { :depth => :hour }
    end
    
    def initialize(scope, label_name = nil, time_stamp = nil, opts = {})
      parse_options(opts)
      self.scope = scope
      self.label = label_name if !label_name.nil?
      self.date = time_stamp ||= Time.now
    end
    
    def prefix
      key = "#{@scope}"
      key << "/#{label.name}" if !label.nil?
      key << ":"
      key
    end
    
    def date=(input)
      @date = (input.instance_of?(Redistat::Date)) ? input : Date.new(input) # Redistat::Date, not ::Date
    end
    attr_reader :date
    
    def depth
      options[:depth]
    end
    
    def scope
      @scope.to_s
    end
    
    def scope=(input)
      @scope = (input.instance_of?(Redistat::Scope)) ? input : Scope.new(input)
    end
    
    def label=(input)
      @label = (input.instance_of?(Redistat::Label)) ? input : Label.create(input, @options)
    end
    attr_reader :label
    
    def label_hash
      @label.hash
    end
    
    def parent
      @parent ||= self.class.new(self.scope, @label.parent, self.date, @options) unless @label.parent.nil?
    end
    
    def children
      db.smembers("#{scope}#{LABEL_INDEX}#{@label}").map { |member|
        child_label = [@label, member].reject { |i| i.nil? }
        self.class.new(self.scope, child_label.join(GROUP_SEPARATOR), self.date, @options)
      }
    end
    
    def update_index
      @label.groups.each do |label|
        # break if label.parent.nil?
        parent = (label.parent || "")
        db.sadd("#{scope}#{LABEL_INDEX}#{parent}", label.me)
      end
    end
    
    def groups # TODO: Is this useless?
      @groups ||= @label.groups.map do |label|
        self.class.new(@scope, label, self.date, @options)
      end
    end
    
    def to_s(depth = nil)
      depth ||= @options[:depth]
      key = self.prefix
      key << @date.to_s(depth)
      key
    end
    
  end
end