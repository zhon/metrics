#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2005.  All rights reserved.
#


require_relative 'test/unit'

require_relative 'conditionalcollector'


class ConditionalCollectorTest < Test::Unit::TestCase
  def setup
    @collector = ConditionalCollector.new
    @collector.collect("foo.c", self)
    @collector.collect("bar.c", self)
  end

  def test_collect
    expected = {
      ConditionalCollector::MAX_SWITCH => [12, "func1", "foo.c"],
      ConditionalCollector::MAX_CASE => [15, "func2", "foo.c"],
      ConditionalCollector::MAX_IF => [3, "func1", "foo.c"],
      ConditionalCollector::CONDS => {'bar.c'=>28, 'foo.c'=>28}
    }

    assert_equal(expected, @collector.result)
  end

  def conditionals #sw cas if
    { 'func2' => [1, 15, 2],
      'func1' => [12, 8, 3] 
    }
  end
end
