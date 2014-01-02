#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#



require 'reporter'
require 'find'
require 'excludes'
require 'datestamp'
require 'fileparser'

class DuplicateReporter < Reporter

  def initialize(collector)
    @lines = collector.result[DuplicateCollector::LINES]
    @worst_files_first = []
    @total_lines = collector.result[DuplicateCollector::TOTAL_LINES]
    @duplicated_lines = collector.result[DuplicateCollector::DUPLICATED_LINES]
  end

  def percent
    @percent_duplication ||= (100 * @duplicated_lines/@total_lines.to_f)
  end

  def summary
    report = "\nDuplicated Lines Summary:\n"

    report << <<-TOTALS

   Total unique, pertinent lines: #{@total_lines}
   Number of lines occurring more than once: #{@duplicated_lines}
   Percentage of duplicate lines #{percent}%
    TOTALS

    report << sumarize_individual_files
    return report
  end

  def sumarize_individual_files
    data = {}
    line_count = 0;

    @lines.each { |key, value|
      value['file-name'].each { |file_name, size_array|
        unless data[file_name]
          data[file_name] = {
            'line-count' => 0,
            'duplicate' => 0
          }
        end
        data[file_name]['line-count'] += size_array.length
        data[file_name]['duplicate'] += 1 if size_array.length > 1
      }
    }

    data.each { |file_name, info|
      data[file_name]['percent-duplication'] = 0 == info['line-count'] ? 0 :
                    100 * (info['duplicate'] / info['line-count'].to_f)
    }


    @worst_files_first = data.sort{ |a,b|
              b[1]['percent-duplication'] <=> a[1]['percent-duplication'] }
    @worst_percent = @worst_files_first[0][1]['percent-duplication']
    return "   Highest percent duplication within a file:  #{@worst_percent}%"
  end

  def details(maximum)
    exdup_count = 0
    report = "\n\nTop #{maximum} Most Frequently Duplicated Lines:\n"

    @lines.sort{ |a,b| b[1]['count'] <=> a[1]['count'] }.each { |key,value|
    exdup_count += 1
      break if (1 == value['count'])
      break if (exdup_count > maximum.to_i)

      report << "\nThe line: '#{key.to_s}' occurs #{value['count'].to_s} total times in\n"
      value['file-name'].each { |key, value|
        report << '   ' + key + ' at line(s) '
        report << value.join(" ")
        report << "\n"
      }
    }

    report << "\n\nTop #{maximum} Files With Internal Duplication:\n\n"

    indup_count = 0
    @worst_files_first.each{ |info|
    indup_count += 1
    break if indup_count > maximum.to_i
    file_name = info[0]

    if info[1]['duplicate'] > 0
      report << <<-REPORT
-----------------------------------------------------------------------------
File:  #{file_name}
Proportion of duplicated lines in file:  #{info[1]['percent-duplication']}%
Number of unique duplicated lines:  #{info[1]['duplicate']}
-----------------------------------------------------------------------------

      REPORT
    end
    }

    return report
  end

  def create_gnuplot_output(path)
    write_output("#{path}exdup.dat", percent)
    write_output("#{path}indup.dat", @worst_percent)
  end

end
