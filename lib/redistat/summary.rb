module Redistat
  class Summary
    include Database
    
    def self.update_all(key, stats = {}, depth_limit = nil, connection_ref = nil, enable_grouping = nil)
      stats ||= {}
      return nil if stats.size == 0
      
      depth_limit ||= key.depth
      enable_grouping = true if enable_grouping.nil?
      
      if enable_grouping
        stats = inject_group_summaries(stats)
        key.groups.each { |k|
          update_key(k, stats, depth_limit, connection_ref)
        }
      else
        update_key(key, stats, depth_limit, connection_ref)
      end
    end
    
    private
    
    def self.update_key(key, stats, depth_limit, connection_ref)
      Date::DEPTHS.each do |depth|
        update(key, stats, depth, connection_ref)
        break if depth == depth_limit
      end
    end
    
    def self.update(key, stats, depth, connection_ref = nil)
      stats.each do |field, value|
        db(connection_ref).hincrby key.to_s(depth), field, value
      end
    end
    
    def self.inject_group_summaries!(stats)
      stats.each do |key, value|
        parts = key.to_s.split(GROUP_SEPARATOR)
        parts.pop
        if parts.size > 0
          sum_parts = []
          parts.each do |part|
            sum_parts << part
            sum_key = sum_parts.join(GROUP_SEPARATOR)
            (stats.has_key?(sum_key)) ? stats[sum_key] += value : stats[sum_key] = value
          end
        end
      end
      stats
    end
    
    def self.inject_group_summaries(stats)
      inject_group_summaries!(stats.clone)
    end
    
  end
end