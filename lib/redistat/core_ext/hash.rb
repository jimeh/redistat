class Hash
  
  def merge_and_incr(hash)
    raise ArgumentError unless hash.is_a?(Hash)
    hash.each do |key, value|
      if value.is_a?(Numeric)
        self.set_or_incr(key, value)
      else
        self[key] = value
      end
    end
  end
  
  def set_or_incr(key, value)
    return self unless value.is_a?(Numeric)
    self[key] = 0 unless self.has_key?(key)
    self[key] += value if self[key].is_a?(Numeric)
    self
  end
  
end
