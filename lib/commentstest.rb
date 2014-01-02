#!/usr/bin/env ruby
#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#

require_relative 'test/unit'

require_relative 'comments'
require_relative 'comment'


class CommentsTest < Test::Unit::TestCase
  attr_reader :comments

  def setup
    @comments = Comments.new
  end

  def test_empty
    assert_equal(0, comments.count)
  end

  def test_one
    comments.add(Comment.new("comment", 1))
    assert_equal(1, comments.count)
  end

end
