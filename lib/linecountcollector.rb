#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2005.  All rights reserved.
#


class LineCountCollector
  #TODO - clearify the names
  TOTAL_COMMENT_LINES = :TOTAL_COMMENT_LINES
  TOTAL_FUNC_LINES =    :TOTAL_FUNCTION_LINES
  TOTAL_GLOBAL_LINES =  :TOTAL_GLOBAL_LINES
  TOTAL_FILES =         :TOTAL_FILES
  TOTAL_FUNCS =         :TOTAL_FUNCIONS
  TOTAL_CODE_LINES =    :TOTAL_CODE_LINES

  MAX_COMMENT =         :LARGEST_COMMENT
  MAX_COMMENT_FILE =    :LARGEST_COMMENT_FILE
  MAX_GLOBAL =          :LARGEST_GLOBAL
  MAX_GLOBAL_FILE =     :LARGEST_GLOBAL_FILE
  MAX_FUNC =            :LARGEST_FUNCTION
  MAX_FUNC_FILE =       :LARGEST_FUNCION_FILE
  MAX_FUNC_NAME =       :LARGEST_FUNCTION_NAME

  MAX_NUM_FUNCS =       :LARGEST_FUNCTION_COUNT
  MAX_NUM_FUNC_FILE =   :LARGEST_FUNCTION_COUNT_FILE

  FILE_STATS = :FILE_STATS

  def initialize
    @max_comment = @max_global = @max_func = @max_num_funcs = 0

    @total_comment_lines = @total_func_lines = @total_global_lines = 0
    @total_files = @total_funcs = @total_code_lines = 0

    @max_comment_file = @max_global_file = @max_func_file = ''
    @max_func_name = @max_num_func_file = ''

    @file_stats={}
  end

  def collect(file_name, file_parser)
    collect_line_counts(file_name, file_parser.counts)
  end

  def finalize
  end

  def result
    { MAX_COMMENT => @max_comment,
      MAX_GLOBAL => @max_global,
      MAX_FUNC => @max_func,
      MAX_NUM_FUNCS => @max_num_funcs,
      TOTAL_COMMENT_LINES => @total_comment_lines,
      TOTAL_FUNC_LINES =>    @total_func_lines,
      TOTAL_GLOBAL_LINES =>  @total_global_lines,
      TOTAL_FILES =>         @total_files,
      TOTAL_FUNCS =>         @total_funcs,
      TOTAL_CODE_LINES =>    @total_code_lines,
      MAX_COMMENT_FILE => @max_comment_file,
      MAX_GLOBAL_FILE => @max_global_file,
      MAX_FUNC_FILE    => @max_func_file,
      MAX_FUNC_NAME     => @max_func_name,
      MAX_NUM_FUNC_FILE => @max_num_func_file,
      FILE_STATS => @file_stats
    }
  end

  def update_func_stats(item, lines, file)
    if item == 'comment'
      @total_comment_lines += lines
      if @max_comment < lines
        @max_comment = lines
        @max_comment_file = file
      end
    elsif item == 'global'
      @total_global_lines += lines
      @total_code_lines += lines
      if @max_global < lines
        @max_global = lines
        @max_global_file = file
      end
    else
      @total_func_lines += lines
      @total_code_lines += lines
      @total_funcs += 1
      if @max_func < lines
        @max_func = lines
        @max_func_file = file
        @max_func_name = item
      end
    end
  end

  def collect_line_counts(file_name, func_counts)
    @total_files += 1
    if @max_num_funcs < func_counts.size
      @max_num_funcs = func_counts.size
      @max_num_func_file = file_name
    end

    func_counts.each do |item, lines|
      update_func_stats(item, lines, file_name)
    end
    func_counts.delete('comment')
    func_counts.delete('global')
    if 0 != func_counts.length
      @file_stats[file_name] = func_counts.sort { |a,b| b[1] <=> a[1] }
    end
  end

end
