#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2005.  All rights reserved.
#
require 'helper'

require 'literalcollector'


class LiteralCollectorTest < Test::Unit::TestCase
  def test_all
    collector = LiteralCollector.new
    collector.collect('foo', self)
    collector.collect('bar', self)
    collector.finalize

    expected = {
      :TOTAL_LITERALS=>6,
      :LITERALS=> {
        "hello"=> {
          "foo"=>[1, 5], 
          "bar"=>[1, 5]
        }, 
        "5"=> {
          "foo"=>[7], 
          "bar"=>[7]
        }
      }
    }
    assert_equal expected, collector.result
  end

  # FileParser mock
  def literals
    literals = []
    literals.push Token.new(1, Literal, "hello")
    literals.push Token.new(5, Literal, "hello")
    literals.push Token.new(7, Literal, "5")
    literals
  end
end

