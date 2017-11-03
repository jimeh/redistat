# Redis gem 4.0 renames the client method to _client
# If we alias that method here then it will be compatatible with Redis >= 2.6

class Redis
  alias_method :client, :_client if method_defined? :_client
end