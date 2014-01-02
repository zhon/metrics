#
# C/C++/Java (and C#?) Extreme Code Metrics program
# Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2005. All rights reserved.
#

class Comment
  attr_reader :comment, :starting_line, :line_count

  def initialize(comment, starting_line)
    @comment = comment
    @starting_line = starting_line
    @line_count = comment.lines.length
  end

  def to_a
    [@comment, @starting_line, @line_count]
  end
  
  def to_s
    return comment
  end
end
