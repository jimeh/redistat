module Redistat
  module Model
    include Database
    include Options
    
    def self.included(base)
      base.extend(self)
    end
    
    
    #
    # statistics store/fetch methods
    # 
    
    def store(label, stats = {}, date = nil, opts = {}, meta = {})
      Event.new(name, label, date, stats, options.merge(opts), meta).save
    end
    alias :event :store

    def fetch(label, from, till, opts = {})
      find(label, from, till, opts).all
    end
    alias :lookup :fetch

    def find(label, from, till, opts = {})
      Finder.new( { :scope => self.name,
                    :label => label,
                    :from  => from,
                    :till  => till }.merge(options.merge(opts)) )
    end
    
    
    #
    # options methods
    #
    
    option_accessor :depth
    option_accessor :class_name
    option_accessor :store_event
    option_accessor :hashed_label
    option_accessor :label_indexing
    
    alias :scope :class_name
    
    def connect_to(opts = {})
      Connection.create(opts.merge(:ref => name))
      options[:connection_ref] = name
    end
    
    
    #
    # resource access methods
    #
    
    def connection
      db(options[:connection_ref])
    end
    alias :redis :connection
    
    def name
      options[:class_name] || (@name ||= self.to_s)
    end
      
  end
end