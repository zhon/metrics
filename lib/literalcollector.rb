#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2005.  All rights reserved.
#

class LiteralCollector
  TOTAL_LITERALS = :TOTAL_LITERALS
  LITERALS = :LITERALS

  def initialize
    @literals = {}
    @total_literals = 0
  end

  def collect(file_name, file_parser)
    # TODO remove the exclude duplication 
    # TODO use a file glob for test and get from options. pass in test_glob
    return if /[Tt]est\./.match(file_name)
    @total_literals += file_parser.literals.length
    literals = file_parser.literals
    literals.each do |item|
      @literals[item.value] ||= {}
      @literals[item.value][file_name] ||= []
      @literals[item.value][file_name].push(item.line_num)
    end
  end

  def finalize
  end

  def result
    { TOTAL_LITERALS => @total_literals,
      LITERALS => @literals
    }
  end

end
