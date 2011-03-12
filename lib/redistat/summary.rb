module Redistat
  class Summary
    include Database
    
    def self.default_options
      { :enable_grouping => true,
        :label_indexing => true,
        :connection_ref => nil }
    end
    
    def self.update_all(key, stats = {}, depth_limit = nil, opts = {})
      stats ||= {}
      return nil if stats.size == 0
      
      options = default_options.merge((opts || {}).reject { |k,v| v.nil? })
      
      depth_limit ||= key.depth
      
      if options[:enable_grouping]
        stats = inject_group_summaries(stats)
        key.groups.each do |k|
          update_key(k, stats, depth_limit, options[:connection_ref])
          k.update_index if options[:label_indexing]
        end
      else
        update_key(key, stats, depth_limit, options[:connection_ref])
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
      summaries = {}
      stats.each do |key, value|
        parts = key.to_s.split(GROUP_SEPARATOR)
        parts.pop
        if parts.size > 0
          sum_parts = []
          parts.each do |part|
            sum_parts << part
            sum_key = sum_parts.join(GROUP_SEPARATOR)
            (summaries.has_key?(sum_key)) ? summaries[sum_key] += value : summaries[sum_key] = value
          end
        end
      end
      stats.merge_and_incr!(summaries)
    end
    
    def self.inject_group_summaries(stats)
      inject_group_summaries!(stats.clone)
    end
    
  end
end