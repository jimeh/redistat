
require "redis"
require "date"
require "time"
require "json/pure"
require "digest/sha1"

require "redistat/database"
require "redistat/model"
require "redistat/event"
require "redistat/key"
require "redistat/label"
require "redistat/date"
require "redistat/scope"

module Redistat
  
  KEY_NEXT_ID = ".next_id"
  KEY_EVENT = ".event:"
  KEY_LEBELS = "Redistat.lables:"
  KEY_EVENT_IDS = ".event_ids"

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
  #   Ohm.connect(:port => 6380)
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




















