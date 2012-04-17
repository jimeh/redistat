module Redistat
  module Options

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def option_accessor(*opts)
        opts.each do |option|
          define_method(option) do |*args|
            if !args.first.nil?
              options[option.to_sym] = args.first
            else
              options[option.to_sym] || nil
            end
          end
        end
      end
    end

    def parse_options(opts)
      opts ||= {}
      @raw_options = opts
      @options = default_options.merge(opts.reject { |k,v| v.nil? })
    end

    def default_options
      {}
    end

    def options
      @options ||= {}
    end

    def raw_options
      @raw_options ||= {}
    end

  end
end
