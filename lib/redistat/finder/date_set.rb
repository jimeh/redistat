module Redistat
  class Finder
    class DateSet < Array
      
      def initialize(start_date = nil, end_date = nil, depth = nil, interval = false)
        if !start_date.nil? && !end_date.nil?
          find_date_sets(start_date, end_date, depth, interval)
        end
      end

      def find_date_sets(start_date, end_date, depth = nil, interval = false)
        start_date = start_date.to_time if start_date.is_a?(::Date)
        end_date = end_date.to_time if end_date.is_a?(::Date)
        if !interval
          find_date_sets_by_magic(start_date, end_date, depth)
        else
          find_date_sets_by_interval(start_date, end_date, depth)
        end
      end

      private

      def find_date_sets_by_magic(start_date, end_date, depth = nil)
        depth ||= :hour
        depths = Date::DEPTHS[Date::DEPTHS.index(:year), Date::DEPTHS.index(depth)+1].reverse
        depths.each_with_index do |d, i|
          sets = [find_start_keys_for(d, start_date, end_date, (i == 0))]
          sets << find_end_keys_for(d, start_date, end_date, (i == 0))
          sets.each do |set|
            self << set if set != { :add => [], :rem => [] }
          end
        end
        self
      end

      def find_date_sets_by_interval(start_date, end_date, depth, inclusive = true)
        depth ||= :hour
        self << { :add => start_date.map_beginning_of_each(depth, :include_start => inclusive, :include_end => inclusive).until(end_date) { |t| t.to_rs.to_s(depth) }, :rem => [] }
      end

      def find_start_keys_for(unit, start_date, end_date, lowest_depth = false)
        return find_start_year_for(start_date, end_date, lowest_depth) if unit == :year
        index = Date::DEPTHS.index(unit)
        nunit = Date::DEPTHS[(index > 0) ? index-1 : index]
        if start_date < start_date.beginning_of_closest(nunit) || start_date.next(nunit).beginning_of(nunit) > end_date.beginning_of(nunit)
          add = []
          start_date.beginning_of_each(unit, :include_start => lowest_depth).until(start_date.end_of(nunit)) do |t|
            add << t.to_rs.to_s(unit) if t < end_date.beginning_of(unit)
          end
          { :add => add, :rem => [] }
        else
          { :add => [start_date.beginning_of(nunit).to_rs.to_s(nunit)],
            :rem => start_date.beginning_of(nunit).map_beginning_of_each(unit, :include_start => true, :include_end => !lowest_depth).until(start_date) { |t| t.to_rs.to_s(unit) } }
        end
      end

      def find_end_keys_for(unit, start_date, end_date, lowest_depth = false)
        return find_end_year_for(start_date, end_date, lowest_depth) if unit == :year
        index = Date::DEPTHS.index(unit)
        nunit = Date::DEPTHS[(index > 0) ? index-1 : index]
        has_nunit = end_date.prev(nunit).beginning_of(nunit) >= start_date.beginning_of(nunit)
        nearest_nunit = end_date.beginning_of_closest(nunit)
        if end_date >= nearest_nunit && has_nunit
          add = []
          end_date.beginning_of(nunit).beginning_of_each(unit, :include_start => true, :include_end => lowest_depth).until(end_date) do |t|
            add << t.to_rs.to_s(unit) if t > start_date.beginning_of(unit)
          end
          { :add => add, :rem => [] }
        elsif has_nunit
          { :add => [end_date.beginning_of(nunit).to_rs.to_s(nunit)], 
            :rem => end_date.map_beginning_of_each(unit, :include_start => !lowest_depth).until(end_date.end_of(nunit)) { |t| t.to_rs.to_s(unit) } }
        else
          { :add => [], :rem => [] }
        end
      end

      def find_start_year_for(start_date, end_date, lowest_depth = false)
        if start_date.years_since(1).beginning_of_year < end_date.beginning_of_year
          { :add => start_date.map_beginning_of_each_year(:include_end => lowest_depth).until(end_date) { |t| t.to_rs.to_s(:year) }, :rem => [] }
        else
          { :add => [], :rem => [] }
        end
      end

      def find_end_year_for(start_date, end_date, lowest_depth = false)
        if lowest_depth
          { :add => [end_date.beginning_of_year.to_rs.to_s(:year)], :rem => [] }
        else
          { :add => [], :rem => [] }
        end
      end
      
    end
  end
end