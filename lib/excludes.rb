#!/usr/bin/env ruby
#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#


class Excludes
  FILES = %w( )

  LINES = %w/else break; break #endif return; continue; #else try finally public: private: protected: void int default: ( ) * { } ;/

  def file?(file)
    FILES.each { | partial_path |
      if Regexp.new(partial_path).match(file)
        return true
      end
    }
    false
  end

  def line?(line)
    remove_comments(line)
    remove_whitespace(line)

    if ! line.empty?
      LINES.include?(line)
    else
      true
    end
  end

  def remove_comments(line)
    line.gsub!(%r{//.*}, '')
    line.gsub!(%r{/\*.*?\*/}, '')   # /* hello world */ code
    line.gsub!(%r{/\*.*}, '')   
    line.gsub!(%r{.*?\*/}, '')   
    line.sub!(%r{^\s*\*[* ].*}, '')   
    line
  end

  def remove_whitespace(line)
    line.strip!
  end
end
