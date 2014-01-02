#!/usr/bin/env ruby
#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#


# TODO remove the duplications that is mutiple MockFileParsers
class MockFileParser
  attr_accessor :imports, :comments

  def initialize
    @imports = []
    @comments = []
  end

  def dead_code_line_numbers
    return  [2, 5, 7]
  end

  def functions
    return { 'func' => { 'call_count' => 0 ,
               'declaration' => 1 }
         }
  end
end

=begin
class MockFileParser
  attr_reader :comments

  def initialize(comments = nil)
    @comments = comments
  end

end
=end
