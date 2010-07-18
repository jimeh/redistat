module Redistat
  class Model
    
    def self.create(*args)
      Event.new(self.name, self.options, *args)
    end
    
    def self.options
      @options ||= {}
    end
    
  end
end