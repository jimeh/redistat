class Bignum
  include Redistat::DateHelper

  def to_time
    Time.at(self)
  end

end
