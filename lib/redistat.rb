
require 'rubygems'
require 'date'
require 'time'
require 'digest/sha1'
require 'monitor'

# Active Support 2.x or 3.x
require 'active_support'
if !{}.respond_to?(:with_indifferent_access)
  require 'active_support/core_ext/hash/indifferent_access'
  require 'active_support/core_ext/hash/reverse_merge'
end

require 'time_ext'
require 'redis'
require 'json'

require 'redistat/mixins/options'
require 'redistat/mixins/synchronize'
require 'redistat/mixins/database'
require 'redistat/mixins/date_helper'

require 'redistat/connection'
require 'redistat/buffer'
require 'redistat/collection'
require 'redistat/date'
require 'redistat/event'
require 'redistat/finder'
require 'redistat/key'
require 'redistat/label'
require 'redistat/model'
require 'redistat/result'
require 'redistat/scope'
require 'redistat/summary'
require 'redistat/version'

require 'redistat/core_ext'


module Redistat

  KEY_NEXT_ID = ".next_id"
  KEY_EVENT = ".event:"
  KEY_LABELS = "Redistat.labels:" # used for reverse label hash lookup
  KEY_EVENT_IDS = ".event_ids"
  LABEL_INDEX = ".label_index:"
  GROUP_SEPARATOR = "/"

  class InvalidOptions < ArgumentError; end
  class RedisServerIsTooOld < Exception; end

  class << self

    attr_writer :group_separator

    def buffer
      Buffer.instance
    end

    def buffer_size
      buffer.size
    end

    def buffer_size=(size)
      buffer.size = size
    end

    def thread_safe
      Synchronize.thread_safe
    end

    def thread_safe=(value)
      Synchronize.thread_safe = value
    end

    def connection(ref = nil)
      Connection.get(ref)
    end
    alias :redis :connection

    def connection=(connection)
      Connection.add(connection)
    end
    alias :redis= :connection=

    def connect(options)
      Connection.create(options)
    end

    def flush
      puts "WARNING: Redistat.flush is deprecated. Use Redistat.redis.flushdb instead."
      connection.flushdb
    end

    def group_separator
      @group_separator ||= GROUP_SEPARATOR
    end

  end
end


# ensure buffer is flushed on program exit
Kernel.at_exit do
  Redistat.buffer.flush(true)
end
