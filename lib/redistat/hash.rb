module Redistat
  class Hash < ::Hash

    def set_or_incr(key, value)
      self[key] = 0 if !self.has_key?(key)
      self[key] += value
      self
    end

  end
end