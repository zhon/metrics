#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#

require 'helper'

require 'commandline'


class CommandLineTest < Minitest::Test

  attr_reader :options, :cli, :usage_line

  def setup; set_up; end
  def set_up
    @usage_line = 'command [options] <other args>'

    @options = [
    [ "--a-option", "-a",  GetoptLong::NO_ARGUMENT, 'description of a option'],
    [ "--b-is-a-very-very-long-option", "-b",  GetoptLong::NO_ARGUMENT, 'b option'] 
    ]
    @cli = CommandLine.new(usage_line, options)
  end

  def test_usage
    expected = <<-USAGE 

#{usage_line}
  -a, --a-option\t\t\tdescription of a option
  -b, --b-is-a-very-very-long-option\tb option
        USAGE

    assert_equal(expected, cli.usage) 
  end

  def test_usage_boundry_conditions
    expected = <<-USAGE 

#{usage_line}
  -c, --c-is-15\t\tshould be size 15
  -d, --d--is-16\tshould be size 16
  -e, --e---is-17\tshould be size 17
    USAGE

    options.clear
    options.push(
      [ "--c-is-15", "-c",  GetoptLong::NO_ARGUMENT, 'should be size 15'],
      [ "--d--is-16", "-d",  GetoptLong::NO_ARGUMENT, 'should be size 16'],
      [ "--e---is-17", "-e",  GetoptLong::NO_ARGUMENT, 'should be size 17'] 
    )
    cli = CommandLine.new(usage_line, options)

    assert_equal(expected, cli.usage) 
  end

  def test_get_opts
    ARGV[0] = '--a-option'
    assert_equal('--a-option', cli.options.get[0])
  end

end

