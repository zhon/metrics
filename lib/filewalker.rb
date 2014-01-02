#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2005.  All rights reserved.
#

class FileWalker
  def initialize(start_dir, include_globs=%w(*), exclude_globs=[])
    @start_dir = start_dir
    @include_globs = include_globs
    @exclude_globs = exclude_globs
  end

  def walk
    Find.find(@start_dir) do |file|
      Find.prune if excluded? file
      next if File.directory? file
      next unless included? file
      yield file
    end
  end

  def excluded?(file)
    cluded?(@exclude_globs, file)
  end

  def included?(file)
    cluded?(@include_globs, file)
  end

  def cluded?(clude, file) 
    clude.any? { |item| File.fnmatch(item, File.basename(file)) }
  end
end
