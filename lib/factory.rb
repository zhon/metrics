#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2005.  All rights reserved.
#


require 'conditionalcollector'
require 'deadcodecollector'
require 'dependencycollector'
require 'duplicatecollector'
require 'linecountcollector'
require 'literalcollector'
require 'testfileratiocollector'
require 'todocollector'

class Factory

  def initialize
    @reporters = []
    @collectors = []
  end
  
  def create_reporters(collectors)
    collectors.each do |item|
      /(.*)Collector/ =~ item.class.to_s
      if $1
        klass = eval("#{$1}Reporter")
        reporter = klass.new(item)
      else
        reporter = item
      end
      @reporters.push(reporter)
    end
    @reporters
  end

  def create_collectors(options)
    @collectors.push(ConditionalCollector.new) if options.conditionals
    @collectors.push(DeadCodeCollector.new) if options.dead_code
    @collectors.push(DependencyCollector.new) if options.dependencies
    @collectors.push(DuplicateCollector.new) if options.duplication
    @collectors.push(LineCountCollector.new) if options.line_count
    @collectors.push(LiteralCollector.new) if options.literals
    @collectors.push(TestFileRatioCollector.new) if options.test_file_ratio
    @collectors.push(TodoCollector.new) if options.todos
    @collectors
  end

end
