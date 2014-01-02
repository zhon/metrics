#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2005.  All rights reserved.
#


class DuplicateCollector
  # TODO - since we have all lines why do we need total lines and duplicate lines?  it just seems like a query to me.
  LINES = :LINES
  TOTAL_LINES = :TOTAL_LINES
  DUPLICATED_LINES = :DUPLICATED_LINES

  def initialize
    @lines = {}
    @percent_duplication = 0
    @worst_files_first = []
    @total_lines = 0
    @duplicated_lines = 0
  end

  def collect(file_name, file_parser)
    collect_unique_lines(file_name, file_parser.lines)
  end

  def finalize
    calculate_duplication
  end

  def result
    { LINES => @lines,
      TOTAL_LINES => @total_lines,
      DUPLICATED_LINES => @duplicated_lines
    }
  end

  def collect_unique_lines(file_name, lines)
    line_num = 0
    lines.each do |line|
      line_num += 1
      next if Excludes.new.line?(line)

      collect_line(line, line_num, file_name)
    end
  end

  def collect_line(line, line_num, file_name)
    initialize_collector(line)
    @lines[line]['count'] += 1
    @lines[line]['file-name'][file_name] =
      [] unless @lines[line]['file-name'][file_name]

    @lines[line]['file-name'][file_name].push(line_num)
  end

  def initialize_collector(line)
    if nil == @lines[line]
      @lines[line] = {
        'count' => 0,
        'file-name' => {},
      }
    end
  end

  def calculate_duplication
    @lines.each { |key, value|
      @duplicated_lines += 1 if value['count'] > 1
      @total_lines += value['count'];
    }
  end

end

