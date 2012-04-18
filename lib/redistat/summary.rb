module Redistat
  class Summary
    include Database

    class << self

      def default_options
        {
          :enable_grouping => true,
          :label_indexing  => true,
          :connection_ref  => nil,
          :expire          => {}
        }
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

      def update(key, stats, depth_limit, opts = {})
        if opts[:enable_grouping]
          stats = inject_group_summaries(stats)
          key.groups.each do |k|
            update_key(k, stats, depth_limit, opts)
            k.update_index if opts[:label_indexing]
          end
        else
          update_key(key, stats, depth_limit, opts)
        end
      end

      private

      def update_key(key, stats, depth_limit, opts = {})
        Date::DEPTHS.each do |depth|
          update_fields(key, stats, depth, opts)
          break if depth == depth_limit
        end
      end

      def update_fields(key, stats, depth, opts = {})
        stats.each do |field, value|
          db(opts[:connection_ref]).hincrby key.to_s(depth), field, value
        end

        if opts[:expire] && !opts[:expire][depth].nil?
          db(opts[:connection_ref]).expire key.to_s(depth), opts[:expire][depth]
        end
      end

      def inject_group_summaries!(stats)
        summaries = {}
        stats.each do |key, value|
          parts = key.to_s.split(Redistat.group_separator)
          parts.pop
          if parts.size > 0
            sum_parts = []
            parts.each do |part|
              sum_parts << part
              sum_key = sum_parts.join(Redistat.group_separator)
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
