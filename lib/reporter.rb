#!/usr/bin/env ruby
#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#



require 'datestamp'

class Reporter
  def collect(file_name, file_parser)
    throw "virtual exception"
  end

  def summary
    ''
  end

  def details(max)
    ''
  end

  def create_gnuplot_output(path)
    throw "virtual exception"
  end

protected
  def write_output(file_path, data)
    lines_file = File.new(file_path, 'a+');
    lines_file.puts("#{Datestamp.fractional_month(Time.new)}\t#{data}");
    lines_file.close();
  end
end
