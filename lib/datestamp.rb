#!/usr/bin/env ruby
#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#


SecondsInDay = 60 * 60 * 24

class Datestamp
  def Datestamp.fractional_month(now)
    year = now.year
    month = now.mon
    hour = now.hour
    min = now.min
    sec = now.sec
  
    next_month = month + 1
    next_month = 1 if next_month == 13
    first_day_of_next_month=Time.mktime(year,next_month,1,hour,min,sec,0)
    last_day_of_this_month = first_day_of_next_month - SecondsInDay
    
    return (year-2001)*12 + month + (now.day / last_day_of_this_month.day.to_f)
  end
end

if $0 == __FILE__
  if (!ARGV.empty?)
    file_line = File.new(ARGV[0]).gets
    print "#{Datestamp.fractional_month(Time.new)}\t#{file_line}"
  else
    print Datestamp.fractional_month(Time.new)
  end
end
