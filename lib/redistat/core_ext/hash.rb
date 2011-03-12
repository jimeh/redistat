class Hash
  
  def merge_and_incr(hash)
    self.clone.merge_and_incr!(hash)
  end
  
  def merge_and_incr!(hash)
    raise ArgumentError unless hash.is_a?(Hash)
    hash.each do |key, value|
      self[key] = value unless self.set_or_incr(key, value)
    end
    self
  end
  
  def set_or_incr(key, value)
    return false unless value.is_a?(Numeric)
    self[key] = 0 unless self.has_key?(key)
    return false unless self[key].is_a?(Numeric)
    self[key] += value
    true
  end
  
end
