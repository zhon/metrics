#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#

require 'tokentype'

class Token
  attr_accessor :type, :value, :line_num

  DIRECTIVE = 'directive'
  
  C_COMMENT = 'c comment'
  CPP_COMMENT = 'cpp comment'
  EOL = 'end of line'

  MATCHED_OP = 'matched operator'  # ( ) { }

  #design for the future (really so i don't have to relook it up :-(
  REL_OP = 'relation operator'  # < <= <=> ... (not the ... operator)
  NUM = 'number'

  def Token.const_missing(symbol)
    object = convert_const_to_new_object(symbol)
    const_set(symbol, object)
  end

  def Token.convert_const_to_new_object(symbol)
    name = convert_symbol_to_valid_class_name(symbol)
    raise "class #{name} doesn't exist" unless Object.const_defined? name.to_sym
    object = eval("#{name}.new") 
  end

  def Token.convert_symbol_to_valid_class_name(symbol)
    name = symbol.to_s
    name.split('_').map {|item| item.capitalize! }.join
  end
  
  def initialize(line_num, type, value=type)
    @line_num = line_num
    @type = type
    @value = value
  end
end

