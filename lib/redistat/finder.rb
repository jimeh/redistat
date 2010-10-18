module Redistat
  class Finder
    include Database
    
    attr_reader :options
    
    def initialize(options = {})
      @options = options
    end
    
    def valid_options?
      return true if !@options[:scope].blank? && !@options[:label].blank? && !@options[:from].blank? && !@options[:till].blank?
      false
    end
    
    def find(options = {})
      @options.merge!(options)
      return nil if !valid_options?
      sets = Finder::DateSet.new(@options[:from], @options[:till], @options[:depth], @options[:interval])
      key = Key.new(@options[:scope], @options[:label])
      total_sum = Result.new
      sets.each do |set|
        sum = Result.new
        sum = summarize_add_keys(set[:add], key, sum)
        sum = summarize_rem_keys(set[:rem], key, sum)
        sum.each do |k, v|
          total_sum.set_or_incr(k, v.to_i)
        end
      end
      total_sum.date = Date.new(@options[:from], @options[:depth])
      total_sum.till = Date.new(@options[:till], @options[:depth])
      total_sum
    end
    
    def summarize_add_keys(sets, key, sum)
      sets.each do |date|
        db.hgetall("#{key.prefix}#{date}").each do |k, v|
          sum.set_or_incr(k, v.to_i)
        end
      end
      sum
    end
    
    def summarize_rem_keys(sets, key, sum)
      sets.each do |date|
        db.hgetall("#{key.prefix}#{date}").each do |k, v|
          sum.set_or_incr(k, -v.to_i)
        end
      end
      sum
    end
    
    class << self
    
      def find(*args)
        new.find(*args)
      end
      
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