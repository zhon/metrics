#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2005.  All rights reserved.
#

require 'helper'

require 'options'
require 'stringio'

class OptionsTest < Test::Unit::TestCase
  def test_usage_from_help
    my_output, tmp_output = capture_output

    assert_raises(SystemExit) { Options.new(['-h']) }
    assert_raises(SystemExit) { Options.new(['--hel']) }
    assert_match /^Usage: /, my_output.string
  ensure
    restore_output(tmp_output)
  end

  def test_usage_from_error
    my_output, tmp_output = capture_output

    assert_raises(SystemExit) { Options.new([]) }
    assert_match /^Error: /, my_output.string
  ensure
    restore_output(tmp_output)
  end

  def test_missing_argument
    my_output, tmp_output = capture_output

    assert_raises(SystemExit) { Options.new(['-v', '-a' 'path']) }
    assert_match /^Error:.*path/, my_output.string
  ensure
    restore_output(tmp_output)
  end

  def test_no_metrics_selected
    my_output, tmp_output = capture_output

    assert_raises(SystemExit) { Options.new(['only/a/path']) }
    assert_match /^Error: no metrics/, my_output.string
  ensure
    restore_output(tmp_output)
  end

  def test_option_line_count
    options = Options.new(['-l', 'start/dir'])
    assert options.line_count
  end

  def test_dependencies_and_includes_are_the_same
    options = Options.new(%w(-i start/dir))
    assert options.dependencies
    options = Options.new(%w(-c start/dir))
    assert options.dependencies
  end

  def test_all_options
    command_line= %w(-a -c -d -i -l -e -s -t -u -r -v 50 -g path start/dir)

    options = Options.new(command_line)
    assert options.conditionals
    assert options.dependencies
    assert options.duplication
    assert options.dead_code
    assert options.line_count
    assert options.literals
    assert options.test_file_ratio
    assert options.todos
    assert_equal 50, options.verbose
    assert_equal 'path', options.gnuplot
    assert_equal ['start/dir'], options.start_dirs
  rescue SystemExit => e
    add_error e
  end

  def test_all_get_all_options
    options = Options.new(['-a', 'start/dir'])
    assert options.conditionals
    assert options.dependencies
    assert options.duplication
    assert options.dead_code
    assert options.line_count
    assert options.literals
    assert options.test_file_ratio
    assert options.todos
  rescue SystemExit => e
    add_error e
  end

  def test_dead_code_option
    command_line= %w(-u start/dir)

    options = Options.new(command_line)
    assert options.dead_code
  rescue SystemExit => e
    add_error e
  end

  def test_verbose_option_is_a_integer
    command_line= %w(-l -v 50 start/dir)

    options = Options.new(command_line)
    assert_equal 50.class, options.verbose.class
    assert_equal 50.class, options.detail_level.class
  rescue SystemExit => e
    add_error e
  end


  def test_default_exclude_globs
    command_line= %w(-l start/dir)

    options = Options.new(command_line)
    assert_equal Array, options.exclude_globs.class
    assert_equal 0, options.exclude_globs.size
  rescue SystemExit => e
    add_error e
  end

  def test_default_include_globs
    command_line= %w(-l start/dir)

    options = Options.new(command_line)
    assert_equal Array, options.include_globs.class
    assert_equal '*.java', options.include_globs[0]
  rescue SystemExit => e
    add_error e
  end

# Testing the yaml options
  def test_options_from_yaml_file
    command_line= %w(-f testfile.yml -l start/dir)
    yaml_filename = command_line[1]
    File.open(yaml_filename, 'w') do |file|
      file.puts <<-EOD
      exclude:
        - dir
        - file.java
      include: 
        - "*.java"
        - "*.cpp"
        - "*.cc"
        - "*.c"
        - "*.h"
        - "*.hpp"
      EOD
    end

    options = Options.new(command_line)
    assert_equal %w(dir file.java), options.exclude_globs
    assert_equal %w(*.java *.cpp *.cc *.c *.h *.hpp), options.include_globs
  rescue SystemExit => e
    add_error e
  ensure
    File.delete(yaml_filename)
  end

  def test_yaml_exclude_globs_is_empty_array
    command_line= %w(-f testfile.yml -l start/dir)
    yaml_filename = command_line[1]
    File.open(yaml_filename, 'w') do |file|
      file.puts <<-EOD
      include:
        - java
      EOD
    end

    options = Options.new(command_line)
    assert_equal [], options.exclude_globs
  rescue SystemExit => e
    add_error e
  ensure
    File.delete(yaml_filename)
  end

  def test_yaml_missing_extensions_gets_default_values
    command_line= %w(-f testfile.yml -l start/dir)
    yaml_filename = command_line[1]
    File.open(yaml_filename, 'w') do |file|
      file.puts <<-EOD
      exclude:
        - dir
      EOD
    end

    options = Options.new(command_line)
    refute_equal [], options.include_globs
    assert options.include_globs.include?('*.java')
  end

  # TODO test bad yaml input provides a meaningful message

private
  def capture_output
    my_output = StringIO.new
    tmp_output, $stdout = $stdout, my_output
    [my_output, tmp_output]
  end

  def restore_output(tmp_output)
    $stdout = tmp_output
  end

end
