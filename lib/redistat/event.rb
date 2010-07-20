module Redistat
  class Event
    include Database
    extend Database
    
    attr_reader :id
    attr_reader :key
    
    attr_accessor :stats
    attr_accessor :meta
    attr_accessor :options
    
    def initialize(scope, label = nil, date = nil, stats = {}, meta = {}, options = {}, is_new = true)
      @options = default_options.merge(options)
      @key = Key.new(scope, label, date, @options)
      @stats = stats ||= {}
      @meta = meta ||= {}
      @new = is_new
    end

    def default_options
      { :depth => :hour, :store_event => false }
    end
    
    def new?
      @new
    end
    
    def save
      return false if !self.new?
      @id = self.class.next_id
      
      #TODO store sumarized stats
      
      if @options[:store_event]
        db.hset "#{KEY_EVENT_PREFIX}#{@id}", :scope, self.scope
        db.hset "#{KEY_EVENT_PREFIX}#{@id}", :label, self.label
        db.hset "#{KEY_EVENT_PREFIX}#{@id}", :date, self.date.to_time.to_s
        db.hset "#{KEY_EVENT_PREFIX}#{@id}", :stats, self.stats.to_json
        db.hset "#{KEY_EVENT_PREFIX}#{@id}", :meta, self.meta.to_json
        db.hset "#{KEY_EVENT_PREFIX}#{@id}", :options, self.options.to_json
        db.sadd "#{self.scope}#{KEY_EVENT_IDS_SUFFIX}", @id
      end
      @new = false
      self
    end
    
    def self.create(*args)
      self.new(*args).save
    end
    
    def self.next_id
      db.incr(KEY_NEXT_EVENT_ID)
    end
    
    def self.find(id)
      event = db.hgetall "#{KEY_EVENT_PREFIX}#{id}"
      return nil if event.size == 0
      self.new( event["scope"], event["label"], event["date"], JSON.parse(event["stats"]),
                      JSON.parse(event["meta"]), JSON.parse(event["options"]), false )
    end
    
    def date
      @key.date
    end
    
    def date=(input)
      @key.date = input
    end
    
    alias :time :date
    alias :time= :date=
    
    def scope
      @key.scope
    end
    
    def scope=(input)
      @key.scope = input
    end
    
    def label
      @key.label
    end
    
    def label_hash
      @key.label_hash
    end
    
    def label=(input)
      @key.label = input
    end
    
  end
end