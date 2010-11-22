module Redistat
  class Label
    include Database
    
    attr_reader :raw
    
    def initialize(str, options = {})
      @options = options
      @raw = str.to_s
    end
    
    def name
      @options[:hashed_label] ? hash : @raw
    end
    
    def hash
      @hash ||= Digest::SHA1.hexdigest(@raw)
    end
    
    def save
      @saved = (db.set("#{KEY_LEBELS}#{hash}", @raw) == "OK") if @options[:hashed_label]
      self
    end
    
    def saved?
      @saved ||= false
    end
    
    def self.create(name, options = {})
      self.new(name, options).save
    end
    
  end
end