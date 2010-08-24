module Redistat
  class Finder
    
    attr_reader :options
    
    def initialize(options = {})
      @options = options
    end
    
    def builder
      
    end
    
    def valid_options?
      return true if !@options[:scope].blank? && !@options[:label].blank? && !@options[:from].blank? && !@options[:till].blank?
      false
    end
    
    class << self
      
      def scope(scope)
        new.scope(scope)
      end
      
      def label(label)
        new.label(label)
      end
      
      def dates(from, till)
        new.dates(from, till)
      end
      alias :date :dates
      
      def from(date)
        new.from(date)
      end
      
      def till(date)
        new.till(date)
      end
      alias :untill :till
      
      def depth(unit)
        new.depth(unit)
      end
      
      def interval(unit)
        new.interval(unit)
      end
      
    end
    
    def scope(scope)
      @options[:scope] = scope
      self
    end
    
    def label(label)
      @options[:label] = label
      self
    end
    
    def dates(from, till)
      from(from).till(till)
    end
    alias :date :dates
    
    def from(date)
      @options[:from] = date
      self
    end
    
    def till(date)
      @options[:till] = date
      self
    end
    alias :until :till
    
    def depth(unit)
      @options[:depth] = unit
      self
    end
    
    def interval(unit)
      @options[:interval] = unit
      self
    end
    
  end
end