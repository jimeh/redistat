module Redistat
  module Model
    include Redistat::Database
    
    def self.included(base)
      base.extend(self)
    end
    
    def store(label, stats = {}, date = nil, meta = {}, opts = {})
      Event.new(name, label, date, stats, options.merge(opts), meta).save
    end
    alias :event :store
    
    def connect_to(opts = {})
      Connection.create(opts.merge(:ref => name))
      options[:connection_ref] = name
    end
    
    def connection
      db(options[:connection_ref])
    end
    alias :redis :connection
    
    def fetch(label, from, till, opts = {})
      Finder.find({
        :scope => name,
        :label => label,
        :from  => from,
        :till  => till
      }.merge(options.merge(opts)))
    end
    alias :lookup :fetch
    
    def hashed_label(boolean = nil)
      if !boolean.nil?
        options[:hashed_label] = boolean
      else
        options[:hashed_label] || nil
      end
    end
    
    def class_name(class_name = nil)
      if !class_name.nil?
        options[:class_name] = class_name
      else
        options[:class_name] || nil
      end
    end
    alias :scope :class_name
    
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
      options[:class_name] || (@name ||= self.to_s)
    end
    
  end
end