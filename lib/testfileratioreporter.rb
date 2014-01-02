#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#

require 'reporter'

class TestFileRatioReporter < Reporter

  def initialize(collector)
    @test_files = collector.result[:TOTAL_TEST_FILES]
    @source_files = collector.result[:TOTAL_SOURCE_FILES]
  end

  def ratio
    @source_files != 0 ? @test_files / @source_files.to_f : 'N/A'
  end

  def summary
    return <<-EOD

Test File Ratio Summary:

   Number of Unit Test Files: #{@test_files}
   Number of Source Files: #{@source_files}
   Ratio of Test Files to Source Files: #{ratio}
   EOD
  end

	def create_gnuplot_output(path)
		write_output("#{path}test_ratio.dat", ratio)
	end
end
