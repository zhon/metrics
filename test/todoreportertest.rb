#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2005.  All rights reserved.
#

require 'helper'

require 'todoreporter'

require 'comment'
require 'comments'
require 'mockfileparser'
require 'todocollector'

class TodoReporterTest < Test::Unit::TestCase
  attr_reader :reporter, :file_parser

  def setup
    comment1 = "TODO hello\nTODOworld"
    comment2 = 'todo cpp todo'
    comment3 = 'just a comment'

    comments = Comments[
            Comment.new(comment1, 2),
            Comment.new(comment2, 3),
            Comment.new(comment3, 5)]

    @file_parser = MockFileParser.new
    file_parser.comments = comments

    collector = TodoCollector.new
    collector.collect('filename1', file_parser)
    collector.collect('filename2', file_parser)

    file_parser.comments = Comments[Comment.new(comment2, 7)]
    collector.collect('filename3', file_parser)

    @reporter = TodoReporter.new(collector)
  end

  def test_summary
    summary = reporter.summary
    assert_match(/Summary.*TODO.*5/m, summary)
    assert_match(/files.*3/m, summary)
  end

  def test_details
    assert_match(/filename1: \["2 ", "3/, reporter.details(20))
  end

  def test_details_are_sorted
    assert_match(/filename1|2.*filename1|2.*filename3/, reporter.details(20))
  end

  def test_details_only_report_up_to_max
    refute_match(/filename3/, reporter.details(2))
  end
end
