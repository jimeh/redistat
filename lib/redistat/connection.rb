module Redistat
  module Connection
    
    REQUIRED_SERVER_VERSION = "1.3.10"
    
    class << self
      
      def get(ref = nil)
        ref ||= :default
        connections[references[ref]] || create
      end
      
      def add(conn, ref = nil)
        ref ||= :default
        check_redis_version(conn)
        references[ref] = conn.client.id
        connections[conn.client.id] = conn
      end
      
      def create(options = {})
        #TODO clean/remove all ref-less connections
        ref = options.delete(:ref) || :default
        options.reverse_merge!(default_options)
        conn = (connections[connection_id(options)] ||= connection(options))
        references[ref] = conn.client.id
        conn
      end
      
      def connections
        @connections ||= {}
      end
      
      def references
        @references ||= {}
      end
      
      private
      
      def check_redis_version(conn)
        raise RedisServerIsTooOld if conn.info["redis_version"] < REQUIRED_SERVER_VERSION
        conn
      end
      
      def connection(options)
        check_redis_version(Redis.new(options))
      end
      
      def connection_id(options = {})
        options.reverse_merge!(default_options)
        "redis://#{options[:host]}:#{options[:port]}/#{options[:db]}"
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