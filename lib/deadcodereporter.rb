#!/usr/bin/env ruby
#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2005.  All rights reserved.
#


require_relative 'reporter'

class DeadCodeReporter < Reporter

  def initialize(collector)
    @dead_code = collector.result[DeadCodeCollector::DEAD_CODE]
    @total = collector.result[DeadCodeCollector::TOTAL]
    @func_names = collector.result[DeadCodeCollector::FUNC_NAMES]
    @uncalled_count = collector.result[DeadCodeCollector::UNCALLED_COUNT]
  end

  def summary
    <<-EOD

Unused/Commented Out Code Summary:

   Total blocks of dead code:  #{@total}
   Total uncalled functions: #{@uncalled_count}
    EOD
  end

  def details(max)
    report = ""

    if 0 != @total
      report = "\n\nDead Code Blocks:\n"
      @dead_code.sort.each do |file, lines|
        report << "   File: #{file}  line(s):  "
        report << lines.join(' ')
        report << "\n"
      end
    end

    if 0 != @func_names.length
      report << "\nUnused (dead) functions:\n"
      @func_names.each do |item|
        report << "   " << item[0] << " (in file: #{item[1]})\n"
      end
    end

    report
  end

  def create_gnuplot_output(path)
    write_output("#{path}dead.dat", @total)
    write_output("#{path}unused.dat", @uncalled_count)
  end

end
