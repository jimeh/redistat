module Redistat
  module Database
    def db
      Redistat.redis
    end
  end
end