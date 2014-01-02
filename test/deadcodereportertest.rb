#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2005.  All rights reserved.
#


require 'helper'

require 'deadcodereporter'
require 'deadcodecollector'
require 'mockfileparser'


class DeadCodeReporterTest < Test::Unit::TestCase
  def setup
    collector = DeadCodeCollector.new
    collector.collect("file1", MockFileParser.new)
    collector.collect("file2", MockFileParser.new)
    collector.collect("file3", MockFileParser.new)
    collector.collect("file4", BlankMockFileParser.new)
    collector.finalize

    @reporter = DeadCodeReporter.new(collector)
  end

  def test_total
    expected = <<-EOD

Unused/Commented Out Code Summary:

   Total blocks of dead code:  9
   Total uncalled functions: 1
    EOD

    assert_equal expected, @reporter.summary
  end

  def test_details_text
    expected = <<-EOD


Dead Code Blocks:
   File: file1  line(s):  2 5 7
   File: file2  line(s):  2 5 7
   File: file3  line(s):  2 5 7

Unused (dead) functions:
   func (in file: file3)
    EOD

    assert_equal expected, @reporter.details(3)
  end

  def test_details
    assert_match /file1.*2 5 7/, @reporter.details(50)
    assert_match /file3.*2 5 7/, @reporter.details(50)
    assert /file4/ !~ @reporter.details(50)
  end

  def test_no_dead_code
    blank_report = DeadCodeReporter.new(get_collector(BlankMockFileParser.new))
    assert_match /0/, blank_report.summary
    assert_equal "", blank_report.details(50)
  end

  def test_unused_function
    report = DeadCodeReporter.new(get_collector(MockFileParser.new))
    assert_match /1/, report.summary
    assert_match /func.*foo/, report.details(50)
  end

  def test_exclude_unused_test_function
    report = DeadCodeReporter.new(get_collector(MockTestFileParser.new))
    assert_match /0/, report.summary
    assert ! (/testFunc/ =~ report.details(50))
  end

  def get_collector(file_parser)
    collector = DeadCodeCollector.new
    collector.collect('foo', file_parser)
    collector.finalize
    collector
  end

end


class BlankMockFileParser
  def dead_code_line_numbers
    []
  end

  def functions
    {}
  end
end

class MockTestFileParser
  def dead_code_line_numbers
    [2, 5, 7]
  end

  def functions
    { 'xxxtestFunc' => { 'call_count' => 0 , 'declaration' => 1 } }
  end
end
