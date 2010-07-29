module Redistat
  module Database
    def self.included(base)
      base.extend(Database)
    end
    def db
      Redistat.redis
    end
  end
end