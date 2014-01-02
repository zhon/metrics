#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2005.  All rights reserved.
#

class Progress
  def initialize(start_dirs, start_time=Time.new, output=$stderr)
    @start_dirs = start_dirs
    @start_time = start_time
    @output = output
  end

  def title
    @output.puts <<-TITLE

    Gathering metrics for #{@start_dirs}:

Lines\tFile
    TITLE
  end

  def current_file(file_name, size)
    @output.printf("%5d\t%s\n", size,
              file_name #.sub(Regexp.escape(@start_dirs),'')
              )
  end

  def finished
    @output.puts"\nProcessing took #{Time.new - @start_time} seconds."
  end
end

