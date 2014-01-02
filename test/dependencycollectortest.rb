#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2005.  All rights reserved.
#

require 'helper'

require 'dependencycollector'

require 'dependencyreportertest'

class DependencyCollectorTest < Test::Unit::TestCase
  def setup
    @collector = DependencyCollector.new
    @collector.collect("aaron.h", AaronMockFileParser.new)
    @collector.collect("stand_alone_header.h", BlankMockFileParser.new)
    @collector.collect("axent.h", AxentMockFileParser.new)
    @collector.collect("output.h", OutputMockFileParser.new)
    @collector.collect("mock3.h", Mock3FileParser.new)
    @collector.finalize
  end

  def test_all
    expected = {
      DependencyCollector::NUM_FILES  =>  5,
      DependencyCollector::MAX_FILE => "aaron.h",
      DependencyCollector::INCLUDES => {
        "aaron.h" => ["axent.h", "stand_alone_header.h", "vector"],
        "mock3.h" => ["output.h", "string"],
        "axent.h" => ["mock3.h", "string"],
        "output.h" => ["axent.h", "string"],
        "stand_alone_header.h" => [] },
      DependencyCollector::CYCLES => [
        [["axent.h", "mock3.h", "output.h", "axent.h"]],
        [["mock3.h", "output.h", "axent.h", "mock3.h"]],
        [["output.h", "axent.h", "mock3.h", "output.h"]]],
      DependencyCollector::MAX_INCLUDES => 3,
      DependencyCollector::TOTAL_INCLUDES => 9
    }

    assert_equal expected, @collector.result
  end

end
