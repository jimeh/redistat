module Redistat
  class Label
    include Database
    include Options
    
    def default_options
      { :hashed_label => false }
    end
    
    def self.create(name, opts = {})
      self.new(name, opts).save
    end
    
    def initialize(str, opts = {})
      parse_options(opts)
      @raw = str.to_s
    end
    
    def to_s
      @raw
    end
    
    def name
      @options[:hashed_label] ? hash : self.to_s
    end
    
    def hash
      @hash ||= Digest::SHA1.hexdigest(self.to_s)
    end
    
    def save
      @saved = db.hset(KEY_LABELS, hash, self.to_s) if @options[:hashed_label]
      self
    end
    
    def saved?
      return true unless @options[:hashed_label]
      @saved ||= false
    end
    
    def parent
      @parent ||= groups[1] if groups.size > 1
    end
    
    def me
      self.to_s.split(GROUP_SEPARATOR).last
    end
    
    def groups
      return @groups unless @groups.nil?
      @groups = []
      parent = ""
      self.to_s.split(GROUP_SEPARATOR).each do |part|
        if !part.blank?
          group = ((parent.blank?) ? "" : "#{parent}#{GROUP_SEPARATOR}") + part
          @groups << Label.new(group)
          parent = group
        end
      end
      @groups.reverse!
    end
    
  end
end