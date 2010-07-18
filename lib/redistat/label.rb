module Redistat
  class Label
    include Database
    
    attr_reader :name
    attr_reader :hash
    
    def initialize(str)
      @name = str
      @hash = Digest::SHA1.hexdigest(@name)
    end
    
    def save
      @saved = (db.set("Redistat:lables:#{@hash}", @name) == "OK")
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