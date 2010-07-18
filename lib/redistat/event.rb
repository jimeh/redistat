module Redistat
  class Event
    
    attr_accessor :label
    attr_reader :options
    
    def initialize(scope, options, data = {}, label = nil, time = nil)
      key = [scope]
      key << Digest::SHA1.hexdigest(label) if !label.nil?
      
      time ||= Time.now
      key << time.to_redistat(options ||= nil)
      
      puts key.inspect
    end
    
  end
end