module Redistat
  class Scope
    include Database

    def initialize(name)
      @name = name.to_s
    end

    def to_s
      @name
    end

    def next_id
      db.incr("#{@name}#{KEY_NEXT_ID}")
    end

  end
end
