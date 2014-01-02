#!/usr/bin/env ruby
#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#


require 'helper'

require 'datestamp'


class DatestampTest < Test::Unit::TestCase
  
  def test_timestamp
    fraction = Datestamp.fractional_month(Time.mktime(2001,1,1,12,0,0,0))

    assert_in_delta 1.032, fraction, 0.001
  end

  def test_december
    fraction = Datestamp.fractional_month(Time.mktime(2001,12,5,12,0,0,0))

    assert_in_delta 12.1612903226, fraction, 0.001
  end
end

  
