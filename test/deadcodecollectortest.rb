#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2005.  All rights reserved.
#

require 'helper'

require 'deadcodecollector'
require 'mockfileparser'


class DeadCodeCollectorTest < Test::Unit::TestCase
  def test_all
    collector = DeadCodeCollector.new
    collector.collect("file1", self)
    collector.finalize

    expected = { 
      :TOTAL_UNCALLED_FUNCTIONS=>1,
      :DETAIL_DEAD_CODE_LINES=>{"file1"=>[1, 3, 5, 7]},
      #TODO :DETAIL_UNCALLED_FUNCTIONS=> { 'file1=> ["functon_name"] }
      :DETAIL_UNCALLED_FUNCTIONS=>[["functon_name", "file1"]],  
      :TOTAL_DEAD_CODE_LINES=>4
    }
    assert_equal expected, collector.result
  end

  def dead_code_line_numbers
    [1, 3, 5, 7]
  end

  def functions
    { "functon_name" => { "call_count" => 0, 'declaration' => 1 } }
  end

end
