#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#

require 'helper'

require 'comment'

class CommentTest < Test::Unit::TestCase
  def test_single_line_comment
    comment = Comment.new("comment", 21)
    assert_equal("comment", "#{comment}")
    assert_equal("comment", comment.comment)
    assert_equal(21, comment.starting_line)
    assert_equal(1, comment.line_count)
  end

  def test_mutiple_line_comment
    comment_string = "comment1\ncomment\2"
    comment = Comment.new(comment_string, 21)
    assert_equal(2, comment.line_count)
  end

  def test_to_a
    comment_string = "comment\ncomment"
    start_line = 21
    comment = Comment.new(comment_string, start_line)

    assert_equal [comment_string, start_line, 2], comment.to_a
  end
    
end
