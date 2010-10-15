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
      sum = {}
      sets.each do |set|
        set_sum = summarize_add_keys(set[:add], key, {})
        set_sum = summarize_sub_keys(set[:sub], key, set_sum)
        set_sum.each do |k, v|
          if sum.has_key?(k)
            sum[k] += v.to_i
          else
            sum[k] = v.to_i
          end
        end
      end
      sum
    end
    
    def summarize_add_keys(the_sets, key, sum)
      the_sets.each do |date|
        stat = db.hgetall("#{key.prefix}#{date}")
        stat.each do |k, v|
          if sum.has_key?(k)
            sum[k] += v.to_i
          else
            sum[k] = v.to_i
          end
        end
      end
      sum
    end
    
    def summarize_sub_keys(the_sets, key, sum)
      the_sets.each do |date|
        stat = db.hgetall("#{key.prefix}#{date}")
        stat.each do |k, v|
          if sum.has_key?(k)
            sum[k] -= v.to_i
          else
            sum[k] = -v.to_i
          end
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