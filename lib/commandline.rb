#!/usr/bin/env ruby
#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#

require 'getoptlong'

class CommandLine
  attr_reader :options

  def initialize(usage_line, args)
    @usage_line = usage_line
    @args = args
    opts = @args.collect { |row| row[0..-2] } 
    @options = GetoptLong.new(*opts)
    @options.quiet = true
  end

  def usage(error_message=nil)
    usage = '' 
    usage << "\n#{error_message}" if error_message

    usage << "\n#{@usage_line}\n"
    @args.each do |item|
      usage << "  #{item[1]}, #{item[0]}#{tabs(item)}#{item[-1]}\n"
    end

    return usage
  end

  def tabs(option_line)
    max_option_length = args_to_s(
    @args.max { |a,b| args_to_s(a).length <=> args_to_s(b).length }
    ).length

    tab_count = max_option_length / 8 - args_to_s(option_line).length / 8 + 1
    return "\t" * tab_count
  end

  # TODO make variable options clear.  ex: -v, --verbose <size>
  def args_to_s(option_line) 
    "  #{option_line[1]}, #{option_line[0]}"
  end

end
