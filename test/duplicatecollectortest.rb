#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2005.  All rights reserved.
#


require 'helper'
require 'duplicatecollector'


class DuplicateCollectorTest < Test::Unit::TestCase
  def test_all
    collector = DuplicateCollector.new
    collector.collect('foo.java', self)
    collector.collect('fool.java', self)
    collector.finalize

    expected = {
      DuplicateCollector::TOTAL_LINES=>6,
      DuplicateCollector::DUPLICATED_LINES=>2,
      DuplicateCollector::LINES=> {
        "world"=> {
          "file-name"=> {
            "fool.java"=>[3], 
            "foo.java"=>[3]}, 
            "count"=>2
          },
        "hello"=> {
          "file-name"=> {
            "fool.java"=>[1, 2], 
            "foo.java"=>[1, 2]
          },
          "count"=>4
        }
      }
    }

    assert_equal expected, collector.result
  end

  def lines
    [
      'hello',
      'hello',
      'world'
    ]
  end
end
