module Redistat
  module Database
    def self.included(base)
      base.extend(Database)
    end
    def db(ref = nil)
      Redistat.connection(ref)
    end
  end
end