#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2005.  All rights reserved.
#


class TestFileRatioCollector
  TOTAL_TEST_FILES = :TOTAL_TEST_FILES
  TOTAL_SOURCE_FILES = :TOTAL_SOURCE_FILES

  DEFAULT_TEST_GLOB = '*Test.*'

  # TODO get test_glob from options
  def initialize(test_glob = DEFAULT_TEST_GLOB)
    @total_test_files = 0
    @total_source_files = 0
    @test_glob = test_glob
  end

  def collect(file_name, file_parse)
    if File.fnmatch(@test_glob, file_name)
      @total_test_files += 1 
    else
      @total_source_files += 1 
    end
  end

  def finalize
  end

  #TODO add test methods for the details
  def result
    { TOTAL_TEST_FILES => @total_test_files,
      TOTAL_SOURCE_FILES => @total_source_files
    }
  end
end
