#!/usr/bin/ruby -w

class MyEnumerable
	include Enumerable;

    def each
		%w( ruby ruuby ruuuby perl ).each do |arg|
			yield arg
		end
    end
end

o = MyEnumerable.new();
p o.sort_by { |s| s.length }

