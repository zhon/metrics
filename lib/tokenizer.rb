#!/usr/bin/env ruby
#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#

require 'token'
require 'strscan'

class Tokenizer

  MACROS = %r{#\w+}
  L_PAREN = %r{[(]}
  R_PAREN = %r{\)}
  L_CURLY =/\{/
  R_CURLY =/\}/
  START_C_COMMENT = %r{/\*}
  START_CPP_COMMENT = %r{//\s*}
  SEMICOLON = %r{;}
  START_QUOTE = %r{'|"}
  IDENTIFIER = %r{\w+}   # TODO /([_a-zA-Z]\w*/
  NUMBER = /^([+\-]?\d+(?:\.\d+)?)/
  #SYMBOL =          %r{[\[\]<>/\\.,:;+=!?#\$%^|&*+\-~]}
  SINGLE_OPERATORS = %r{[\[\]<>/\\.,:;+=!?#\$%^|&*+\-~]} #(?![\[\]<>/\\.,:;+=!?#\$%^|&*+\-~])}
  MUTIPLE_OPERATORS = %r{\[\]|<=|>=|!=|\+\+|\+=|-=|\*=|/=|~=|==|<<|>>|<<=|>>=|::|&&|\|\|}
  ANNOTATION = %r{^(@\w*)}
  #TODO handle templates <template>
  #TODO what do we do with '.' (hint remove '.' from SYMBOL above)

  def initialize(file_name)
    @file_name = file_name
    @tokens = []
    @parsed = false
    @current_index = -1
    @line_index = -1
  end

  def parse
    while next_line
      while 1
        skip_ws
        if @scanner.eos?
          add_token(Token::EOL)
          break
        elsif @scanner.scan(L_PAREN)
          add_token(Token::MATCHED_OP, @scanner.matched)
        elsif @scanner.scan(R_PAREN)
          add_token(Token::MATCHED_OP, @scanner.matched)
        elsif @scanner.scan(L_CURLY)
          add_token(Token::MATCHED_OP, @scanner.matched)
        elsif @scanner.scan(R_CURLY)
          add_token(Token::MATCHED_OP, @scanner.matched)
        elsif @scanner.scan(SEMICOLON)
          add_token(Token::SEMICOLON)
        elsif @scanner.skip(START_C_COMMENT)
          do_c_comment
        elsif @scanner.skip(START_CPP_COMMENT)
          comment = @scanner.scan(/.*/) || ''
          add_token(Token::CPP_COMMENT, comment.strip)
        elsif @scanner.scan(MACROS)
          add_token(Token::DIRECTIVE, @scanner.matched)
        elsif @scanner.scan(NUMBER)
          add_token(Token::NUMBER, @scanner.matched)
        elsif @scanner.scan(ANNOTATION)
          add_token(Token::ANNOTATION, @scanner.matched)
        elsif @scanner.scan(START_QUOTE)
          do_quote(@scanner.matched)
        elsif @scanner.scan(IDENTIFIER)
          add_token(Token::IDENTIFIER, @scanner.matched)
        elsif @scanner.scan(MUTIPLE_OPERATORS)
          add_token(Token::OP, @scanner.matched)
        elsif @scanner.scan(SINGLE_OPERATORS)
          add_token(Token::OP, @scanner.matched)
        else
          error('unknown token')
        end
      end
    end
  end

  def skip_ws
    @scanner.skip(/\s*/)
  end

  def do_quote(quote='"')
    line_num = @line_index
    content = ''
    while @scanner
      result = @scanner.scan_until(%r/#{quote}|\\/)
      error unless result
      content << result
      case @scanner.matched
      when '\\'
        if @scanner.eos? or @scanner.check(/\n/)
          content.chop!
          content << "\n"
          next_line
        else
          content << @scanner.getch
        end
      when quote
        content.chop!
        break
      end
    end
    add_token(quote == '"' ? 
              Token::STRING_LITERAL : 
              Token::CHARACTER, 
              content,
              line_num)
  end

  def error(msg='')
    pos = @scanner.pos
    raise <<-EOD
Error: #{msg} while tokenizing
#{@lines[@line_index].chomp}
#{' '*pos}^
#{@file_name}:#{@line_index+1}
    EOD

  end

  def lines
    if @parsed == false
      parse
      @parsed = true
    end
    return @lines
  end

  def next
    if @parsed == false
      parse
      @parsed = true
    end

    @current_index += 1
    return nil if nil == token
    return self
  end

  def token
    @tokens[@current_index]
  end

  def subsequent_token
    @tokens[@current_index + 1]
  end

  def previous_token
    @tokens[@current_index - 1]
  end

private

  def next_line
    @lines = IO.readlines(@file_name) unless @lines
    @line_index += 1
    if @line_index < @lines.length
      @scanner = StringScanner.new(@lines[@line_index])
    else
      @scanner = nil
    end
    @scanner
  end

  def do_c_comment
    line_num = @line_index
    comment = ''
    while @scanner
      if @scanner.scan %r{.*?\s*\*/}
        comment << "\n" unless comment.empty?
        comment << @scanner.matched.chop.chop.strip
        add_token(Token::C_COMMENT, comment, line_num)
        break
      else
        comment << "\n" unless comment.empty?
        comment << @scanner.scan(/.*/).strip
      end
      next_line
    end
    raise "c comment has no close" unless @scanner
  end

  def add_token(type, value=type, line_num=@line_index)
    @tokens.push(Token.new(line_num+1, type, value))
  end
end



if $0 == __FILE__
  if ARGV.size == 0
  else
    tok = Tokenizer.new(ARGV[0])
    while (tok.next)
      if Token::EOL == tok.token.type
        puts
      else
        print tok.token.value, " "
      end
    end
  end
end
