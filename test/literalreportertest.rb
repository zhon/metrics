#!/bin/usr/env ruby
#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#
require 'helper'

require 'literalreporter'
require 'fileparser'

class LiteralReporterTest < Test::Unit::TestCase

  def test_summary
    collector = LiteralCollector.new
    collector.collect("filename", LiteralMockFileParser.new)

    reporter = LiteralReporter.new(collector)

    expected = literal_summary(5, 4, 1)
    assert_equal(expected, reporter.summary)
  end

  def test_literal_reporte_skips_tests
    collector = LiteralCollector.new
    collector.collect("blahTest.java", LiteralMockFileParser.new)
    collector.collect("blahTest.c++", LiteralMockFileParser.new)
    collector.collect("blahtest.c++", LiteralMockFileParser.new)

    reporter = LiteralReporter.new(collector)

    expected = literal_summary(0, 0, 0)
    assert_equal(expected, reporter.summary)
  end

  def test_details
    collector = LiteralCollector.new
    collector.collect("filename", LiteralMockFileParser.new)
    collector.collect("filename2", LiteralMockFileParser.new)

    reporter = LiteralReporter.new(collector)

    expected = <<-DATA

Top 50 Duplicated Constants:

The literal 'Hello world' occurs 4 total times in
    filename2 at line(s) 1 2
    filename at line(s) 1 2

The literal 'Hello again' occurs 2 total times in
    filename2 at line(s) 2
    filename at line(s) 2

    DATA

    assert_match(/'Hello world' occurs 4.*filename2.* 1 2.*filename.* 1 2/m, 
      reporter.details(50))
    assert_match(/'Hello again' occurs 2.*filename2.* 2.*filename.* 2/m, 
      reporter.details(50))
    assert_match(/'c' occurs 2/, reporter.details(50))
    assert_match(/'-3.1415' occurs 2/, reporter.details(50))
  end

  def test_details_only_show_specified_details
    collector = LiteralCollector.new
    collector.collect("filename", LiteralMockFileParser.new)
    collector.collect("filename2", LiteralMockFileParser.new)

    reporter = LiteralReporter.new(collector)

    expected = <<-DATA

Top 1 Duplicated Constants:

The literal 'Hello world' occurs 4 total times in
    filename2 at line(s) 1 2
    filename at line(s) 1 2

    DATA

    assert_equal expected, reporter.details(1)
  end

  class LiteralMockFileParser
    attr_reader :literals

    def initialize
      @literals = [ Token.new(1, Token::STRING_LITERAL, 'Hello world'), 
                    Token.new(2, Token::STRING_LITERAL, 'Hello again'), 
                    Token.new(2, Token::STRING_LITERAL, 'Hello world'),
                    Token.new(3, Token::CHARACTER, 'c'), 
                    Token.new(6, Token::NUMBER, '-3.1415') ]
    end
  end

  def literal_summary(total, unique, duplicate)
    return <<-DATA

Literals Summary:

   Total Literals: #{total}
   Total Unique Literals: #{unique}
   Total Duplicate Literals: #{duplicate}
    DATA
  end

end

