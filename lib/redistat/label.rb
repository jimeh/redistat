module Redistat
  class Label
    include Database
    
    attr_reader :name
    attr_reader :hash
    
    def initialize(str)
      @name = str.to_s
      @hash = Digest::SHA1.hexdigest(@name)
    end
    
    def save
      @saved = (db.set("#{KEY_LEBELS_PREFIX}#{@hash}", @name) == "OK")
      self
    end
    
    def saved?
      @saved ||= false
    end
    
    def self.create(name)
      self.new(name).save
    end
    
  end
end