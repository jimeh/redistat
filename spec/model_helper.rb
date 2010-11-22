require "redistat"

class ModelHelper
  include Redistat::Model
  
  
end

class ModelHelper2
  include Redistat::Model
  
  depth :day
  store_event true
  hashed_label true
  
end