#!/usr/bin/env ruby
#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#



require_relative 'dependencyreporter'

require_relative 'test/unit'
require_relative 'dependencycollector'


class DependencyReporterTest < Test::Unit::TestCase
  def setup
    collector = DependencyCollector.new
    collector.collect("aaron.h", AaronMockFileParser.new)
    collector.collect("stand_alone_header.h", BlankMockFileParser.new)
    collector.collect("axent.h", AxentMockFileParser.new)
    collector.collect("output.h", OutputMockFileParser.new)
    collector.collect("mock3.h", Mock3FileParser.new)
    collector.finalize

    @reporter = DependencyReporter.new(collector)
  end

  def test_maximum_includes
    assert_match /Most.*?3.*aaron.h/, @reporter.summary
  end

  def test_average_includes_summary
    assert_match /Average.*?1.8/, @reporter.summary
  end

  def test_list_of_most_includes
    assert_match   Regexp.new('aaron.h.*2.*axent.h', Regexp::MULTILINE),
            @reporter.details(50)
    assert_match   Regexp.new('aaron.h.*2.*output.h', Regexp::MULTILINE),
            @reporter.details(50)
  end

  def setup_dependencies
    @reporter.collect("aaron.h", AaronMockFileParser.new)
    @reporter.collect("stand_alone_header.h", BlankMockFileParser.new)
    @reporter.collect("axent.h", AxentMockFileParser.new)
    @reporter.collect("output.h", OutputMockFileParser.new)
    @reporter.collect("mock3.h", Mock3FileParser.new)
  end

# TODO THESE TESTS DON'T WORK!!!! FIX THEM!!!!

=begin

  def test_cyclical_dependencies
    details = @reporter.details(50)
    assert_not_match Regexp.new('Cyclical.*stand_alone_header.h', Regexp::MULTILINE), details
    assert_match /axent.h->mock3.h->output.h->axent.h/, details
    assert_match /output.h->axent.h->mock3.h->output.h/, details
  end

  def setup_no_cycles
    @reporter = DependencyReporter.new

    @reporter.collect("aaron.h", AaronMockFileParser.new)
    @reporter.collect("stand_alone_header.h", BlankMockFileParser.new)
  end

  def test_no_cyclical_dependencies
    setup_no_cycles
    details = @reporter.details(50)
    assert_match 'Cyclical.*none', details
    assert_not_match /->/, details
  end

  def test_cyclical_dependencies2
    setup_dependencies(
      'a.h' => ['b.h', 'x.h'],
      'b.h' => ['c.h'],
      'c.h' => ['a.h'],
    )
  end
=end

end

class AxentMockFileParser
  def includes
    return  ["mock3.h", "string"]
  end
end

class OutputMockFileParser
  def includes
    return  ["axent.h", "string"]
  end
end

class BlankMockFileParser

  def includes
    return []
  end
end

class Mock3FileParser
  def includes
    return  ["output.h", "string"]
  end
end

class AaronMockFileParser
  def includes
    return  ['axent.h', 'stand_alone_header.h', 'vector']
  end
end
