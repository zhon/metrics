#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2005.  All rights reserved.
#

class TodoReporter < Reporter
  def initialize(collector)
    @total_comments = collector.result[:TOTAL_COMMENTS]
    @totals = collector.result[:DETAILS]
  end

  def summary
    report = <<-TOTALS

TODO Summary:

   Total TODOs: #{@total_comments}
   Total files containing TODOs: #{@totals.length}
    TOTALS

    return report
  end

  def details(maximum)
    report = "\n\nTop #{maximum} Files with TODOs:\n"
    
    count = 0
    @totals.sort{ |a,b| b[1].length <=> a[1].length }.each do |key,value|
      break if count >= maximum
      report << "  #{key}: #{value.collect{|item| item[1].to_s + " "}}\n"
      count += 1
    end
    return report
  end

  def create_gnuplot_output(path)
		write_output("#{path}/todo.dat", @total_comments)
  end
end

