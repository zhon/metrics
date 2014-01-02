#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2005.  All rights reserved.
#

require 'optparse'
require 'ostruct'
require 'yaml'

class Options
  DEFAULT_INCLUDE_GLOBS = %w(*.java *.c *.cpp *.h *.cc *.cp *.hpp)
  DEFAULT_EXCLUDE_GLOBS = []

  attr_reader :conditionals, :dead_code, :dependencies, :duplication
  attr_reader :line_count, :literals, :test_file_ratio, :todos

  attr_reader :verbose, :gnuplot, :start_dirs
  attr_reader :exclude_globs, :include_globs

  alias detail_level verbose
  alias plot_dir gnuplot

  def initialize(args=ARGV)
    @args = args
    @exclude_globs = DEFAULT_EXCLUDE_GLOBS
    @include_globs = DEFAULT_INCLUDE_GLOBS

    parse_command_line
    inialize_yaml_options
  end

private
  def parse_command_line
    opts = OptionParser.new do |opts|
      script_name = File.basename($0)
      opts.banner = "Usage: ruby #{script_name} [options] <directories>"

      opts.separator ''

      opts.on('-a', '--all-reports',
              'Generate all metrics reports.') { set_all_options }
      opts.on('-c', '--crit-dependencies',
              'Report imports of certain critical packages.') { @dependencies=true }
      opts.on('-d', '--duplication',
              'Find duplicate code.') { @duplication=true }
      opts.on('-f', '--option-file FILE', String,
              'FILE contains program options') { |@options_filename| }
      opts.on('-g', '--gnuplot PATH', String,
              'Produce gnuplot output file to PATH') { |@gnuplot| }
      opts.on('-i', '--includes',
             'Analyze dependencies for quanitity and cycles.') { @dependencies=true }
      opts.on('-l', '--line-count',
             'Count total number of lines in files/functions.') { @line_count=true }
      opts.on('-e', '--literal',
             'Literal count and duplicate literals.') {@literals=true }
      opts.on('-s', '--conditionals',
             'Conditional logic (switch/case, if/else).') { @conditionals=true }
      opts.on('-t', '--todo',
             'Count todo in comments.') {@todos=true }
      opts.on('-u', '--unused',
             'Find unused functions, #if 0 and commented out code.') { @dead_code=true }
      opts.on('-r', '--ratio',
             'Ratio of test files to source files.') { @test_file_ratio=true }
      opts.on('-v', '--verbose SIZE',
             'Display details up to SIZE.') { |size| @verbose=size.to_i }

      opts.on('-h', '--help',
             'Show this help message.') { usage(opts) }

      begin
        @start_dirs = opts.parse! @args
      rescue OptionParser::ParseError => e
        usage(opts, "Error: " + e.to_s.strip)
      end

      verify_options(opts)
    end
  end

  def inialize_yaml_options
    return unless @options_filename
    yaml_file = File.new(@options_filename) 
    obj = YAML::load(yaml_file)
    @exclude_globs = obj['exclude'] if obj['exclude']
    load_include_globs(obj)
  ensure
    yaml_file.close if yaml_file
  end

  def load_include_globs(obj)
    @include_globs = obj['include'] if obj['include']
  end

  def set_all_options
    @conditionals = true
    @dependencies = true
    @duplication = true
    @dead_code = true
    @includes = true
    @line_count = true
    @literals = true
    @test_file_ratio = true
    @todos= true
  end

  def verify_options(opts)
    usage(opts, 'Error: metrics require a path.') if @start_dirs.empty?
    usage(opts, 'Error: no metrics selected') unless
      conditionals or dependencies or dead_code or duplication or
      line_count or literals or conditionals or test_file_ratio or todos
  end

  def usage(usage, error_message=nil)
    output = ''
    output << "\n#{error_message}" if error_message
    output << "\n#{usage}\n"
    puts output
    exit(error_message.nil? ? -1 : 0)
  end
end
