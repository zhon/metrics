#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2005.  All rights reserved.
#

class DeadCodeCollector
  TOTAL = :TOTAL_DEAD_CODE_LINES
  UNCALLED_COUNT = :TOTAL_UNCALLED_FUNCTIONS
  DEAD_CODE = :DETAIL_DEAD_CODE_LINES
  FUNC_NAMES = :DETAIL_UNCALLED_FUNCTIONS

  def initialize
    @dead_code = {}
    @total = 0
    @all_functions = {}
    @func_names = []
    @uncalled_count = 0
  end

  # TODO dead code via ';' should be counted here not in fileparser
  def collect(file_name, file_parser)
    if 0 !=  file_parser.dead_code_line_numbers.length
      @dead_code[file_name] = file_parser.dead_code_line_numbers
    end
    if 0 !=  file_parser.functions.length
      file_parser.functions.each do |func, info|
        next if Regexp.new(eat_first_char(func)) =~ file_name
        @all_functions[func] = {} if nil == @all_functions[func]
        @all_functions[func]['call_count'] = 0 if nil ==
          @all_functions[func]['call_count']
        @all_functions[func]['declaration'] = 0 if nil ==
          @all_functions[func]['declaration']
        @all_functions[func]['file'] = 0 if nil ==
          @all_functions[func]['file']
        @all_functions[func]['call_count'] += info['call_count']
        @all_functions[func]['declaration'] += info['declaration']
        @all_functions[func]['file'] = file_name

      end
    end
  end

  def finalize
    @total = calculate_total

    @all_functions.each do |func, info|
      if nil != info['declaration'] &&
         0 == info['call_count'] &&
         ! (/[Tt]est/ =~ func)    # TODO get the test pattern from options
          @uncalled_count += 1
          @func_names.push([func, info['file']])
      end
    end

  end

  def result
    { DEAD_CODE => @dead_code,
      TOTAL => @total,
      FUNC_NAMES => @func_names,
      UNCALLED_COUNT => @uncalled_count
    }
  end

  def eat_first_char(string)
    string.reverse.chomp.reverse
  end

  def calculate_total
    total = 0
     @dead_code.each do |key, lines|
      total += lines.length
    end
    total
  end

end

