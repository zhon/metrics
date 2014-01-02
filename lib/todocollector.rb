#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2005.  All rights reserved.
#

class TodoCollector

  #TODO get todo from options...allow more than one todo
  def initialize(todo = /TODO/i)
    @todo = todo
    @total = 0
    @details = Hash.new
  end

  def collect(file_name, file_parser)
    file_parser.comments.each do |item|
      if item.comment.grep(@todo).length > 0
        @details[file_name] ||= []
        @details[file_name].push(item.to_a)
        @total += 1
      end
    end
  end

  def finalize
  end

  def result
    { :TOTAL_COMMENTS => @total,
      :DETAILS => @details
    }
  end

end
