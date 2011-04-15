require 'monitor'

module Redistat
  module Synchronize
    
    class << self
      def included(base)
        base.send(:include, InstanceMethods)
      end
      
      def monitor
        @monitor ||= Monitor.new
      end
      
      def thread_safe
        monitor.synchronize do
          @thread_safe ||= false
        end
      end
      
      def thread_safe=(value)
        monitor.synchronize do
          @thread_safe = value
        end
      end
    end # << self
    
    module InstanceMethods
      def thread_safe
        Synchronize.thread_safe
      end
      
      def thread_safe=(value)
        Synchronize.thread_safe = value
      end
      
      def monitor
        Synchronize.monitor
      end
      
      def synchronize(&block)
        if thread_safe
          monitor.synchronize(&block)
        else
          block.call
        end
      end
    end # InstanceMethods
    
  end
end