
require 'rubygems'
require 'active_support'
require 'active_support/hash_with_indifferent_access' if !Hash.respond_to?(:with_indifferent_access) # Active Support 2.x and 3.x
require 'redis'
require 'date'
require 'time'
require 'time_ext'
require 'json'
require 'digest/sha1'

require 'redistat/collection'
require 'redistat/connection'
require 'redistat/database'
require 'redistat/date'
require 'redistat/event'
require 'redistat/finder'
require 'redistat/finder/date_set'
require 'redistat/key'
require 'redistat/label'
require 'redistat/model'
require 'redistat/result'
require 'redistat/scope'
require 'redistat/summary'

require 'redistat/core_ext/date'
require 'redistat/core_ext/time'
require 'redistat/core_ext/fixnum'
require 'redistat/core_ext/bignum'

module Redistat
  
  KEY_NEXT_ID = ".next_id"
  KEY_EVENT = ".event:"
  KEY_LEBELS = "Redistat.lables:"
  KEY_EVENT_IDS = ".event_ids"
  
  class InvalidOptions < ArgumentError; end
  class RedisServerIsTooOld < Exception; end
  
  class << self
    
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
    
  end
end
