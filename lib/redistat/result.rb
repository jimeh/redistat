require 'active_support/core_ext/hash/indifferent_access'

module Redistat
  class Result < HashWithIndifferentAccess
    
    attr_accessor :from
    attr_accessor :till
    
    alias :date :from
    alias :date= :from=
    
    def initialize(options = {})
      @from = options[:from] ||= nil
      @till = options[:till] ||= nil
    end
    
  end
end
