module Redistat
  module Database
    def db
      Redistat.redis
    end
    def self.db
      Redistat.redis
    end
  end
end