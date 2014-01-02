#!/usr/bin/env ruby
#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#



class ParserState
  attr_accessor :parser_context 

  @@name = 'global'

  def name
    return @@name
  end

  def initialize(context)
    @parser_context = context
  end

  def inc_line_count
    parser_context.inc_line_count
  end

  def dec_line_count
    parser_context.dec_line_count
  end

  def change_state(new_state)
    @parser_context.change_state(new_state)
  end
  
  def newline
    inc_line_count
  end

  def declare_function(func_name); end
  def end_param_list; end
  def begin_function_body; end
  def end_function_body; end
  def end_prototype; end
  def add_conditional(type); end
end

class CountLineState < ParserState

  def initialize(parser_context)
    super(parser_context)
    @curly = 1
  end
  def begin_function_body
    @curly += 1
  end

  def declare_function(func_name)
    parser_context.add_function_call(func_name)
  end
  
  def end_function_body
    @curly -= 1
    if (0 == @curly)
      inc_line_count
      parser_context.change_state(GlobalState.new(parser_context))
      dec_line_count
    end
  end

  def add_conditional(type)
    parser_context.add_conditional(@@name, type)
  end
end

class GlobalState < ParserState
  def initialize(parser_context)
    super
  end

  def declare_function(func_name)
    @@name = func_name
    parser_context.add_function_declaration(func_name)
    parser_context.change_state(ParamListState.new(parser_context))
  end

  def name
    'global'
  end
end

class ParamListState < ParserState
  def end_param_list
    parser_context.change_state(BodySearchState.new(parser_context))
  end
end

class BodySearchState < ParserState
  def end_prototype
    parser_context.change_state(GlobalState.new(parser_context))
  end
  
  def begin_function_body
    parser_context.change_state(CountLineState.new(parser_context))
  end
end


