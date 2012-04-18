require 'monitor'

module Redistat
  module Connection

    REQUIRED_SERVER_VERSION = "1.3.10"
    MIN_EXPIRE_SERVER_VERSION = "2.1.3"

    # TODO: Create a ConnectionPool instance object using Sychronize mixin to replace Connection class

    class << self

      # TODO: clean/remove all ref-less connections

      def get(ref = nil)
        ref ||= :default
        synchronize do
          connections[references[ref]] || create
        end
      end

      def add(conn, ref = nil)
        ref ||= :default
        synchronize do
          check_redis_version(conn)
          references[ref] = conn.client.id
          connections[conn.client.id] = conn
        end
      end

      def create(options = {})
        synchronize do
          options = options.clone
          ref = options.delete(:ref) || :default
          options.reverse_merge!(default_options)
          conn = (connections[connection_id(options)] ||= connection(options))
          references[ref] = conn.client.id
          conn
        end
      end

      def connections
        @connections ||= {}
      end

      def references
        @references ||= {}
      end

      private

      def monitor
        @monitor ||= Monitor.new
      end

      def synchronize(&block)
        monitor.synchronize(&block)
      end

      def connection(options)
        check_redis_version(Redis.new(options))
      end

      def connection_id(options = {})
        options = options.reverse_merge(default_options)
        "redis://#{options[:host]}:#{options[:port]}/#{options[:db]}"
      end

      def check_redis_version(conn)
        raise RedisServerIsTooOld if conn.info["redis_version"] < REQUIRED_SERVER_VERSION
        if conn.info["redis_version"] < MIN_EXPIRE_SERVER_VERSION
          STDOUT.puts "WARNING: You MUST upgrade Redis to v2.1.3 or later " +
            "if you are using key expiry."
        end
        conn
      end

      def default_options
        {
          :host => '127.0.0.1',
          :port => 6379,
          :db => 0,
          :timeout => 5
        }
      end

    end
  end
end
