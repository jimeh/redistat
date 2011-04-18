require 'redistat/core_ext/hash'

module Redistat
  class Buffer
    include Synchronize
    
    def self.instance
      @instance ||= self.new
    end
    
    def size
      @size ||= 0
    end
    attr_writer :size
    
    def store(key, stats, depth_limit, opts)
      return false unless should_buffer?
      
      to_flush = {}
      buffkey = buffer_key(key, opts)
      
      synchronize do
        if !queue.has_key?(buffkey)
          queue[buffkey] = { :key         => key,
                             :stats       => {},
                             :depth_limit => depth_limit,
                             :opts        => opts }
        end
        
        queue[buffkey][:stats].merge_and_incr!(hash)
        
        # return items to be flushed if buffer size limit has been reached
        to_flush = reset_queue
      end
      
      # flush any data that's been cleared from the queue
      flush_data(to_flush)
      true
    end
    
    def flush(force = false)
      to_flush = {}
      synchronize do
        to_flush = reset_queue(force)
      end
      flush_data(to_flush)
    end
    
    private
    
    def queue
      @queue ||= {}
    end
    
    def should_buffer?
      size > 1 # buffer size of 1 would be equal to not using buffer
    end
    
    # should always be called from within a synchronize block
    def should_flush?
      (!queue.blank? && queue.size >= size)
    end
    
    # returns items to be flushed if buffer size limit has been reached
    # should always be called from within a synchronize block
    def reset_queue(force = false)
      return {} if !force || should_flush?
      data = queue
      @queue = {}
      data
    end
    
    def flush_data(buffer_data)
      buffer_data.each do |k, item|
        Summary.update(item[:key], item[:stats], item[:depth_limit], item[:connection_ref])
      end
    end
    
    def buffer_key(key, opts)
      # depth_limit is not needed as it's evident in key.to_s
      opts_index = Summary.default_options.keys.sort { |a,b| a.to_s <=> b.to_s }.map do |k|
        opts[k] if opts.has_key?(k)
      end
      "#{key.to_s}:#{opts_index.join(':')}"
    end
    
  end
end
