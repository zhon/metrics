#!/usr/bin/env ruby
#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#

require 'conditionalreporter'
require 'consoleview'
require 'deadcodereporter'
require 'dependencyreporter'
require 'duplicatereporter'
require 'fileparser'
require 'filewalker'
require 'linecountreporter'
require 'literalreporter'
require 'options'
require 'progress'
require 'testfileratioreporter'
require 'todoreporter'
require 'factory'

class Metrics

  def initialize(options, progress)
    @options = options
    @progress = progress
    @factory = Factory.new
    @start_dirs = options.start_dirs
    @collectors = @factory.create_collectors(options)
  end

  def visit_source_files
    @progress.title

    @start_dirs.each do |dir|
      walker = FileWalker.new(dir,
                              @options.include_globs,
                              @options.exclude_globs)
      walker.walk do |file_name|
        parser = FileParser.new(file_name)

        @progress.current_file(file_name, parser.lines.size)

        @collectors.each do |item|
          item.collect(file_name, parser)
        end
      end
    end
    @collectors.each do |item| 
      item.finalize if item.respond_to? :finalize
    end
  end

  def report(output)
    output.puts "\n\nCode Metrics for #{@options.start_dirs}:"
    output.puts

    @factory.create_reporters(@collectors).each do | report |
      output.puts report.summary
      output.puts report.details(@options.detail_level) if @options.detail_level
      report.create_gnuplot_output @options.plot_dir if @options.plot_dir
    end
  end

end

if $0 == __FILE__
  begin
    options = Options.new(ARGV)
    output = ConsoleView.new
    progress = Progress.new(options.start_dirs)

    metrics = Metrics.new(options, progress)
    metrics.visit_source_files
    metrics.report(output)
  ensure
    progress.finished if progress
    output.close if output
  end
end
