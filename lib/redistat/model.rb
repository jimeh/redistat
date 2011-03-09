module Redistat
  module Model
    include Redistat::Database
    
    def self.included(base)
      base.extend(self)
    end
    
    #
    # statistics store/fetch methods
    # 
    
    def store(label, stats = {}, date = nil, meta = {}, opts = {})
      Event.new(name, label, date, stats, options.merge(opts), meta).save
    end
    alias :event :store

    def fetch(label, from, till, opts = {})
      find(label, from, till, opts).all
    end
    alias :lookup :fetch

    def find(label, from, till, opts = {})
      Finder.new( { :scope => name,
                    :label => label,
                    :from  => from,
                    :till  => till }.merge(options.merge(opts)) )
    end
    
    #
    # options methods
    #
    
    def connect_to(opts = {})
      Connection.create(opts.merge(:ref => name))
      options[:connection_ref] = name
    end
    
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
    
    #
    # resource access methods
    #
    
    def connection
      db(options[:connection_ref])
    end
    alias :redis :connection
    
    def options
      @options ||= {}
    end
    
    def name
      options[:class_name] || (@name ||= self.to_s)
    end
      
  end
end