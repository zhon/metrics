#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#


require 'testfileratioreporter'

require 'testfileratiocollector'
require 'test/unit'

class TestFileRatioReporterTest < Test::Unit::TestCase
  attr_reader :test_dir, :reporter

  def setup
    @test_dir = 'test_source'
    @test = "#{test_dir}/my1Test.java"
    @source1 = "#{test_dir}/my2source.cpp"
    @source2 = "#{test_dir}/testsource.java"
  end

  def test_summary
    collector = TestFileRatioCollector.new
    collector.collect(@test, nil)
    collector.collect(@source1, nil)
    collector.collect(@source2, nil)

    reporter = TestFileRatioReporter.new(collector)
    expected = <<-EOD

Test File Ratio Summary:

   Number of Unit Test Files: 1
   Number of Source Files: 2
   Ratio of Test Files to Source Files: 0.5
     EOD
    
    assert_equal(expected, reporter.summary)
  end

  def test_div_zero
    collector = TestFileRatioCollector.new
    collector.collect('fooTest.java', nil)
    reporter = TestFileRatioReporter.new(collector)
    
    expected = <<-EOD

Test File Ratio Summary:

   Number of Unit Test Files: 1
   Number of Source Files: 0
   Ratio of Test Files to Source Files: N/A
     EOD
    
    assert_equal(expected, reporter.summary)
  end

  def test_details
    collector = TestFileRatioCollector.new
    reporter = TestFileRatioReporter.new(collector)
    assert_equal '', reporter.details(5)
  end
end
