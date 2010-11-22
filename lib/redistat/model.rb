module Redistat
  module Model
    
    def self.included(base)
      base.extend(self)
    end
    
    def store(label, stats = {}, date = nil, meta = {}, opts = {})
      Event.new(name, label, date, stats, options.merge(opts), meta).save
    end
    alias :event :store
    
    def fetch(label, from, till, opts = {})
      Finder.find({
        :scope => name,
        :label => label,
        :from  => from,
        :till  => till
      }.merge(options.merge(opts)))
    end
    alias :find :fetch
    
    def hashed_label(boolean = nil)
      if !boolean.nil?
        options[:hashed_label] = boolean
      else
        options[:hashed_label] || nil
      end
    end
    
    def depth(depth = nil)
      if !depth.nil?
        options[:depth] = depth
      else
        options[:depth] || nil
      end
    end
    
    def store_event(boolean = nil)
      if !boolean.nil?
        options[:store_event] = boolean
      else
        options[:store_event] || nil
      end
    end
    
    def options
      @options ||= {}
    end
    
    private
    
    def name
      @name ||= self.to_s
    end
    
  end
end