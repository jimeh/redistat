module Redistat
  class Summary
    include Database
    
    class << self
      
      def default_options
        { :enable_grouping => true,
          :label_indexing => true,
          :connection_ref => nil }
      end
      
      def buffer
        Redistat.buffer
      end
      
      def update_all(key, stats = {}, depth_limit = nil, opts = {})
        stats ||= {}
        return if stats.empty?
        
        options = default_options.merge((opts || {}).reject { |k,v| v.nil? })
        
        depth_limit ||= key.depth
        
        update_through_buffer(key, stats, depth_limit, options)
      end
      
      def update_through_buffer(*args)
        update(*args) unless buffer.store(*args)
      end
      
      def update(key, stats, depth_limit, opts)
        if opts[:enable_grouping]
          stats = inject_group_summaries(stats)
          key.groups.each do |k|
            update_key(k, stats, depth_limit, opts[:connection_ref])
            k.update_index if opts[:label_indexing]
          end
        else
          update_key(key, stats, depth_limit, opts[:connection_ref])
        end
      end
      
      private
      
      def update_key(key, stats, depth_limit, connection_ref)
        Date::DEPTHS.each do |depth|
          update_fields(key, stats, depth, connection_ref)
          break if depth == depth_limit
        end
      end
      
      def update_fields(key, stats, depth, connection_ref = nil)
        stats.each do |field, value|
          db(connection_ref).hincrby key.to_s(depth), field, value
        end
      end
      
      def inject_group_summaries!(stats)
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
      
      def inject_group_summaries(stats)
        inject_group_summaries!(stats.clone)
      end
      
    end
  end
end