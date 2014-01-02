#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2005.  All rights reserved.
#

require 'fileparser'

class ConditionalCollector
  MAX_SWITCH =  :LARGEST_SWITCH
  MAX_CASE =    :LARGEST_CASE
  MAX_IF =      :LARGEST_IF
  CONDS =       :CONDS

  def initialize
    @max_switch = [0]
    @max_case = [0]
    @max_if = [0]
    @conds = {}
  end

  def collect (file_name, file_parser)
    conditionals = file_parser.conditionals

    # TODO move the sorting into conditionals
    # example switches = conditionals.sorted_by_something
    switches = conditionals.sort do |b, a| 
      a[1][FileParser::SWITCH] <=> b[1][FileParser::SWITCH]
    end
    cases = conditionals.sort do |b, a| 
      a[1][FileParser::CASE] <=> b[1][FileParser::CASE] 
    end
    ifs = conditionals.sort do |b, a| 
      a[1][FileParser::IF] <=> b[1][FileParser::IF]
    end
  
    if switches[0] != nil
      if switches[0][1][0] > @max_switch[0]
        @max_switch[0] = switches[0][1][0]
        @max_switch[1] = switches[0][0] #func_name
        @max_switch[2] = file_name
      end
    end

    # TODO do something about the unreadable numbers
    # at least use a constant. a method call is better
    if cases[0] != nil
      if cases[0][1][1] > @max_case[0]
        @max_case[0] = cases[0][1][1]
        @max_case[1] = cases[0][0] #func_name
        @max_case[2] = file_name
      end
    end
    
    if ifs[0] != nil
      if ifs[0][1][2] > @max_if[0]
        @max_if[0] = ifs[0][1][2]
        @max_if[1] = ifs[0][0] #func_name
        @max_if[2] = file_name
      end
    end
    
    conditionals.each_value do |cond|
      @conds[file_name] = 0 if @conds[file_name] == nil
      @conds[file_name] += cond[1]
      @conds[file_name] += cond[2]
    end
  end

  def result
    { MAX_SWITCH => @max_switch,
      MAX_CASE => @max_case,
      MAX_IF => @max_if,
      CONDS => @conds
    }
  end
end
