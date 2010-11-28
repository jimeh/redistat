module Redistat
  class Summary
    include Database
    
    def self.update_all(key, stats = {}, depth_limit = nil, connection_ref = nil)
      stats ||= {}
      depth_limit ||= key.depth
      return nil if stats.size == 0
      Date::DEPTHS.each do |depth|
        update(key, stats, depth, connection_ref)
        break if depth == depth_limit
      end
    end
    
    private
    
    def self.update(key, stats, depth, connection_ref = nil)
      stats.each do |field, value|
        db(connection_ref).hincrby key.to_s(depth), field, value
      end
    end
    
  end
end