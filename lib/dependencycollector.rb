#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2005.  All rights reserved.
#

class DependencyCollector
  TOTAL_INCLUDES =  :TOTAL_INCLUDES
  MAX_INCLUDES =    :LARGEST_INCLUDE
  NUM_FILES =       :NUM_FILES
  MAX_FILE =        :MAX_FILE
  INCLUDES =        :INCLUDES
  CYCLES =          :CYCLES

  def initialize
    @max_includes = 0
    @total_includes = 0
    @num_files = 0
    @max_file = ""
    @includes = {}
    @cycles = []
  end

  def collect(file_name, file_parser)
    length = file_parser.includes.length
    if @max_includes < length
      @max_includes = length
      @max_file = file_name
    end
    @total_includes += length
    @num_files += 1 if /.java$/ !~ file_name
    short_name = file_name.sub(/^.*\//, '')
    @includes[short_name] = file_parser.includes
  end

  def finalize
    calculate_cycles
  end

  def result
    { MAX_INCLUDES => @max_includes,
      TOTAL_INCLUDES => @total_includes,
      NUM_FILES => @num_files,
      MAX_FILE => @max_file,
      INCLUDES => @includes,
      CYCLES => @cycles
    }
  end

  def calculate_cycles
    @includes.keys.grep(/\.hp?p?/).sort.each do |file_name|
      @path = []
      traverse(file_name, 1)
    end 
  end

  def traverse(file_name, depth)
    @path.push(file_name)

    if 2 == @path.grep(file_name).length
      if @path[-1] == @path[0]
        @cycles.push [ @path.clone ]
      end

      @path.pop
      return
    end

    @includes[file_name] and @includes[file_name].sort.each do | next_file |
      traverse(next_file, depth+1)
    end
  end

end
