module Redistat
  class Summary
    include Database
    extend Database
    
    def self.update_all(key, stats = {}, depth_limit = nil)
      stats ||= {}
      depth_limit ||= key.depth
      return false if stats.size == 0
      depths.each do |depth|
        update(key, stats, depth)
        break if depth == depth_limit
      end
    end
    
    private
    
    def self.update(key, stats, depth)
      stats.each do |field, value|
        db.hincrby key.to_s(depth), field, value
      end
    end
    
    def self.depths
      [:year, :month, :day, :hour, :min, :sec, :usec]
    end
    
  end
end