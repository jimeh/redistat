
require 'rubygems'
require 'active_support'
require 'active_support/time' if !Time.respond_to?(:days_in_month) # Active Support 2.x and 3.x
require 'redis'
require 'date'
require 'time'
require 'time/ext'
require 'json'
require 'digest/sha1'

require 'redistat/collection'
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

module Redistat
  
  KEY_NEXT_ID = ".next_id"
  KEY_EVENT = ".event:"
  KEY_LEBELS = "Redistat.lables:"
  KEY_EVENT_IDS = ".event_ids"
  
  class InvalidOptions < ArgumentError; end

  # Provides access to the Redis database. This is shared accross all models and instances.
  def redis
    threaded[:redis] ||= connection(*options)
  end

  def redis=(connection)
    threaded[:redis] = connection
  end

  def threaded
    Thread.current[:redistat] ||= {}
  end

  # Connect to a redis database.
  #
  # @param options [Hash] options to create a message with.
  # @option options [#to_s] :host ('127.0.0.1') Host of the redis database.
  # @option options [#to_s] :port (6379) Port number.
  # @option options [#to_s] :db (0) Database number.
  # @option options [#to_s] :timeout (0) Database timeout in seconds.
  # @example Connect to a database in port 6380.
  #   Redistat.connect(:port => 6380)
  def connect(*options)
    self.redis = nil
    @options = options
  end

  # Return a connection to Redis.
  #
  # This is a wapper around Redis.new(options)
  def connection(*options)
    Redis.new(*options)
  end

  def options
    @options = [] unless defined? @options
    @options
  end

  # Clear the database.
  def flush
    redis.flushdb
  end
  
  module_function :connect, :connection, :flush, :redis, :redis=, :options, :threaded

end




















