module Redistat
  class Collection < ::Array
    
    attr_accessor :from
    attr_accessor :till
    attr_accessor :depth
    attr_accessor :total
    
    def initialize(options = {})
      @from = options[:from] ||= nil
      @till = options[:till] ||= nil
      @depth = options[:depth] ||= nil
    end
    
  end
end