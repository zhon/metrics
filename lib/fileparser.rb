#!/usr/bin/env ruby
#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#



require 'tokenizer'
require 'parserstate'
require 'comments'
require 'comment'

class FileParser
  SWITCH = 0
  CASE = 1
  IF = 2

  attr_reader :dead_code_line_numbers, :functions, :includes, :conditionals
  attr_reader :comments, :literals, :imports

  LeftParen = '('
  RightParen = ')'
  LeftCurly = '{'
  RightCurly = '}'
  Semicolon = ';'
  Identifier = %r{\w}
  PoundIf = '#if'

  def initialize(file_name)
    @file_name = file_name
    @dead_code_line_numbers = []
    @func_line_counts = {}
    @functions = {}
    @includes = []
    @conditionals = {}
    @tok = Tokenizer.new(file_name)
    @comments = Comments.new      # TODO replace this with a real array
    @literals = []
    @imports = []
    parse(file_name)
  end

  def parse(file_name)
    @tok = Tokenizer.new(file_name)
    @state = GlobalState.new(self)

    while @tok.next
      case @tok.token.type
      when Token::DIRECTIVE   # pound something
        case @tok.token.value
        when '#if'
          if '0' == @tok.subsequent_token.value
            @dead_code_line_numbers.push @tok.token.line_num
          else
            while Token::EOL != @tok.next.subsequent_token.type
            end
          end
        when '#include'
          add_include
        end
      when Token::MATCHED_OP
        case @tok::token.value
        when LeftCurly
          @state.begin_function_body
        when RightCurly
          @state.end_function_body
        when RightParen
          @state.end_param_list
        end
      when Token::EOL
        next if nil != @tok.subsequent_token and 
                Token::EOL == @tok.subsequent_token.type
        @state.newline
      when Token::IDENTIFIER
        conditional = which_conditional(@tok.token.value)
        if conditional != nil
          @state.add_conditional(conditional)
        elsif LeftParen == @tok.subsequent_token.value
          @state.declare_function(@tok.token.value)
        elsif @tok.token.value == 'import'
         line = @tok.lines[@tok.token.line_num-1]
         match_data = /import\s+(.*);/.match(line)
         imports.push(match_data[1]) unless match_data == nil
        end
      when Token::CPP_COMMENT
        do_cpp_comment
      when Token::C_COMMENT
        do_c_comment
      when Token::STRING_LITERAL
        literals.push @tok.token
      when Token::SEMICOLON
        @state.end_prototype
      end
    end
    @func_line_counts['comment'] = count_comments
  end

  # TODO remove duplication with do_c_comment
  def do_cpp_comment
    count_dead_code_via_semicolon
    comments.add(Comment.new(@tok.token.value, @tok.token.line_num))

    if Token::EOL == @tok.previous_token.type
      @tok.next
    end
  end

  def do_c_comment
    count_dead_code_via_semicolon
    comments.add(Comment.new(@tok.token.value, @tok.token.line_num))

    #TODO think about why this is here
    if Token::EOL == @tok.previous_token.type
      while nil != @tok.subsequent_token and 
            Token::EOL == @tok.subsequent_token.type
        @tok.next
      end
    end
  end

  def count_comments
    line_count = 0
    comments.each do |item|
      line_count += item.line_count
    end
    return line_count
  end

  def previous_line_is_commented_out_code
    dead_code_line_numbers[-1] == @tok.token.line_num - 1
  end

  def count_dead_code_via_semicolon
    if not previous_line_is_commented_out_code
      if /;/.match(@tok.token.value)
        dead_code_line_numbers.push @tok.token.line_num 
      end
    end
  end

  def lines
    return @tok.lines
  end

  def counts
    @func_line_counts
  end

  def change_state(new_state)
    @state = new_state
  end

  def inc_line_count
    if nil == @func_line_counts[@state.name]
      @func_line_counts[@state.name] = 0
    end
    @func_line_counts[@state.name] += 1
  end

  def dec_line_count
    if nil == @func_line_counts[@state.name]
      @func_line_counts[@state.name] = 0
    end
    @func_line_counts[@state.name] -= 1
  end

  def initialize_function(func_name)
    @functions[func_name] = {} if nil == @functions[func_name]
    @functions[func_name]['call_count'] = 0 if nil == 
          @functions[func_name]['call_count']
    @functions[func_name]['declaration'] = 0 if nil == 
          @functions[func_name]['declaration']
  end

  def add_function_declaration(func_name)
    initialize_function(func_name)
    @functions[func_name]['declaration'] += 1 
  end

  def add_function_call(func_name)
    initialize_function(func_name)
    
    @functions[func_name]['call_count'] += 1 
  end

  def add_include
    while  @tok.next.token.type == Token::C_COMMENT
      do_c_comment
    end

    value = ""
    case @tok.token.type
    when Token::IDENTIFIER
      value = @tok.token.value
    when Token::STRING_LITERAL, Token::CHARACTER
      value = @tok.token.value.delete('"')
      value.sub!(%r{.*/}, '')
      value.sub!(%r{.*\\}, '')
    when Token::OP
      error "Invalid include line", @tok unless '<' == @tok.token.value
      while @tok.next.token.value != '>'
        value << @tok.token.value
        value = "" if %r{/|\\} =~ @tok.token.value
      end
    else
      error "Invalid include line", @tok
    end

    @includes.push value
  end

  def error(msg, tok)
      raise "#{msg} on line '#{tok.lines[tok.token.line_num]}' in file <#{@file_name}> at #{tok.token.line_num}"
  end
  
  def add_conditional(func_name, conditional_type)
    @conditionals[func_name] = [0,0,0] if @conditionals[func_name] == nil
    @conditionals[func_name][conditional_type] += 1
  end
  
  def which_conditional(token)
    if token == 'else' or token == 'if'
      return IF
    elsif token == 'case' or token == 'default'
      return CASE
    elsif token == 'switch'
      return SWITCH
    end
    return nil
  end

end
