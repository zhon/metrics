#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2005.  All rights reserved.
#



require 'reporter'

class LineCountReporter < Reporter

  attr_reader :total_code_lines

  def initialize(collector)
    @max_comment =  collector.result[LineCountCollector::MAX_COMMENT]
    @max_global =   collector.result[LineCountCollector::MAX_GLOBAL]
    @max_func =     collector.result[LineCountCollector::MAX_FUNC]
    @max_num_funcs =collector.result[LineCountCollector::MAX_NUM_FUNCS]

    @total_comment_lines=collector.result[LineCountCollector::TOTAL_CODE_LINES]
    @total_func_lines =  collector.result[LineCountCollector::TOTAL_FUNC_LINES]
    @total_global_lines=collector.result[LineCountCollector::TOTAL_GLOBAL_LINES]
    @total_files = collector.result[LineCountCollector::TOTAL_FILES]
    @total_funcs = collector.result[LineCountCollector::TOTAL_FUNCS]
    @total_code_lines = collector.result[LineCountCollector::TOTAL_CODE_LINES]

    @max_comment_file =collector.result[LineCountCollector::MAX_COMMENT_FILE]
    @max_global_file =collector.result[LineCountCollector::MAX_GLOBAL_FILE]
    @max_func_file =collector.result[LineCountCollector::MAX_FUNC_FILE]
    @max_func_name =collector.result[LineCountCollector::MAX_FUNC_NAME]
    @max_num_func_file =collector.result[LineCountCollector::MAX_NUM_FUNC_FILE]

    @file_stats=collector.result[LineCountCollector::FILE_STATS]
  end

  def longest_function
    @max_func
  end

  def summary
    return <<EOD

Line Count Summary:

   Most comment lines: #{@max_comment} (in file #{@max_comment_file})
   Most global lines: #{@max_global} (in file #{@max_global_file})
   Longest function: #{@max_func} lines (function #{@max_func_name}() in file #{@max_func_file})
   Most functions in file: #{@max_num_funcs} (in file #{@max_num_func_file})

   Total comment lines:  #{@total_comment_lines}
   Total global code: #{@total_global_lines} lines
   Total code: #{@total_code_lines} lines
   Total number of files: #{@total_files}
   Total number of functions: #{@total_funcs}

   Average function length: #{average_function_length} lines
   Average comment lines per file: #{@total_files==0 ? 0 : @total_comment_lines / @total_files}
   Average functions per file: #{@total_files==0 ? 0 : @total_funcs / @total_files}
   Average file length: #{@total_files==0 ? 0 : @total_code_lines / @total_files} lines
EOD
  end

  def details(how_many)
    report = "\n\nTop #{how_many} Files With Long Functions:\n"

    count = 0
    @file_stats.sort {|a,b| b[1][0][1] <=> a[1][0][1]}.each { |key, value|
      key =~ /(\w.*)/
      break if count == how_many
      report << "\n#{$1}\n"
      0.upto(4) { |i|
        if nil != value[i]
          report << print_func(value[i][0], value[i][1])
          report << "\n"
        end
      }
      count += 1
    }
    return report
  end

  def create_gnuplot_output(path)
    write_output("#{path}lines.dat", total_code_lines)
    write_output("#{path}longest.dat", longest_function)
    write_output("#{path}average.dat", average_function_length)
  end

private
  def print_func(name, lines)
    if name != 'global' and name != 'comment'
      return "   #{name}() #{lines}"
    else
      return "   #{name} #{lines}"
    end
  end

  def average_function_length
    @total_funcs==0 ? 0 : @total_func_lines / @total_funcs.to_f
  end

end
