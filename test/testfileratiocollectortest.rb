#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2005.  All rights reserved.
#

require 'helper'

require 'testfileratiocollector'


class TestFileRatioCollectorTest < Test::Unit::TestCase
  def test_all
    collector = TestFileRatioCollector.new
    collector.collect('foo', self)
    collector.collect('bar', self)
    collector.collect('barTest.java', self)
    collector.collect('barTest.h', self)
    collector.collect('barTest.cpp', self)

    expected = {
      :TOTAL_TEST_FILES =>3,
      :TOTAL_SOURCE_FILES =>2
    }
    assert_equal expected, collector.result
  end


end
