module Redistat
  class Label
    include Database
    
    attr_reader :connection_ref
    
    def self.create(name, options = {})
      self.new(name, options).save
    end
    
    def initialize(str, options = {})
      @options = options
      @raw = str.to_s
    end
    
    def to_s
      @raw
    end

    def db
      super(@options[:connection_ref])
    end
    
    def name
      @options[:hashed_label] ? hash : self.to_s
    end
    
    def hash
      @hash ||= Digest::SHA1.hexdigest(self.to_s)
    end
    
    def save
      @saved = (db.set("#{KEY_LEBELS}#{hash}", self.to_s) == "OK") if @options[:hashed_label]
      self
    end
    
    def saved?
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