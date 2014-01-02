#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2005.  All rights reserved.
#
require 'helper'

require 'linecountcollector'


class LineCountCollectorTest < Test::Unit::TestCase
  # TODO write better tests
  def test_all
    collector = LineCountCollector.new
    collector.collect('foo', self)
    collector.finalize

    expected = {
       :LARGEST_FUNCTION_COUNT_FILE=>"foo",
       :LARGEST_GLOBAL_FILE=>"",
       :TOTAL_FUNCTION_LINES=>0,
       :LARGEST_FUNCTION=>0,
       :TOTAL_FUNCIONS=>0,
       :TOTAL_FILES=>1,
       :LARGEST_FUNCION_FILE=>"",
       :TOTAL_CODE_LINES=>0,
       :LARGEST_COMMENT=>5,
       :FILE_STATS=>{},
       :LARGEST_FUNCTION_NAME=>"",
       :LARGEST_COMMENT_FILE=>"foo",
       :TOTAL_GLOBAL_LINES=>0,
       :TOTAL_COMMENT_LINES=>5,
       :LARGEST_FUNCTION_COUNT=>1,
       :LARGEST_GLOBAL=>0
    }
    assert_equal expected, collector.result
  end

  def counts
    { 'comment' => 5
    }
  end
end

