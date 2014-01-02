#!/usr/bin/env ruby
#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#

require 'helper'

require 'conditionalreporter'
require 'conditionalcollector'


class ConditionalReporterTest < Test::Unit::TestCase

  def setup
    @reporter = ConditionalReporter.new(self)
  end

  def test_summary_report
    assert_match(/switch.*12.*func1.*foo.c/, @reporter.summary)
    assert_match(/cases:.*15.*func2.*foo.c/, @reporter.summary)
    assert_match(%r{if/else.*3}, @reporter.summary)
  end

  def test_details
    expected = <<-EOD


Files With Most Conditionals:

   28 bar.c
    EOD

    p @reporter.details(2)
    assert_equal expected, @reporter.details(1)
  end

  def result
    collector = ConditionalCollector.new
    collector.collect("foo.c", self)
    collector.collect("bar.c", self)
    collector.result
  end

  def conditionals #sw cas if
    { 'func2' => [1, 15, 2],
      'func1' => [12, 8, 3] }
  end
end
