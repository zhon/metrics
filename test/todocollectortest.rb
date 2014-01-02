#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2005.  All rights reserved.
#

require 'helper'

require 'todocollector'
require 'comment'

class TodoCollectorTest < Test::Unit::TestCase
  def test_all
    collector = TodoCollector.new
    collector.collect("foo.c", self)
    collector.collect("bar.c", self)

    expected = {
      :TOTAL_COMMENTS=>4,
      :DETAILS=> {
        "bar.c"=>[
          ["comment TODO", 21, 1], 
          ["multi\ntodo line\ncomment", 21, 3]
        ],
        "foo.c"=>[
          ["comment TODO", 21, 1],
          ["multi\ntodo line\ncomment", 21, 3]
        ]
      }
    }

    assert_equal(expected, collector.result)
  end

  def comments
    [ Comment.new("comment TODO", 21),
      Comment.new("multi\ntodo line\ncomment", 21),
      Comment.new("a plain comment", 21)
    ]
  end
end
