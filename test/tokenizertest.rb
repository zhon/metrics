#!/usr/bin/env ruby
#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#

require 'helper'

require 'tokenizer'

class TokenizerTest < Test::Unit::TestCase
  FIlE_NAME = 'test-file.remove'

  def teardown
    File.unlink(FIlE_NAME) if File.exists?(FIlE_NAME)
  end

  def initialize_tokenizer(data) 
    file = File.new(FIlE_NAME, "w+")
    file.print data
    file.close
    return Tokenizer.new(FIlE_NAME)
  end

  def test_strings
    tok = initialize_tokenizer( <<-EOD
        "this is a string" "this \\"is\\" a string"
      EOD
    )
    assert_equal('this is a string', tok.next.token.value) 
    assert_equal(Token::STRING_LITERAL, tok.token.type) 
    assert_equal('this \\"is\\" a string', tok.next.token.value) 
  end

  # remove this TODO and test
  # if you think strings shouldn't terminate at the end of the line
  def xxxtest_three_quotes
    tok = initialize_tokenizer( <<-EOD
      "a""
      'b''
      EOD
    )
    assert_equal('a', tok.next.token.value) 
    assert_equal('', tok.next.token.value) 
    assert_equal(Token::EOL, tok.next.token.type) 
    assert_equal('b', tok.next.token.value) 
    assert_equal('', tok.next.token.value) 
  end

  def test_strings_that_terminate_on_the_next_line
    tok = initialize_tokenizer( <<-EOD
        "two lines \\
        with backslash"
      EOD
    )
    assert_equal("two lines \n        with backslash", tok.next.token.value) 
  end

  def test_three_strings_that_terminate_on_the_next_line
    tok = initialize_tokenizer( <<-EOD
        "one\\
        two\\
        three"
      EOD
    )
    assert_equal("one\n        two\n        three", tok.next.token.value) 
  end

  def test_backslash_with_quote_first_thing_on_next_line
    tok = initialize_tokenizer( <<-EOD
      "\\
"
      EOD
    )
    assert_equal("\n", tok.next.token.value) 
  end

  def test_string_with_backslash_backslash_at_end_works_correctly
    tok = initialize_tokenizer( <<-EOD
      "\\\\"
      EOD
    )
    token = tok.next.token
    assert_equal(Token::STRING_LITERAL, token.type)
    assert_equal('\\\\', token.value)
  end

  def test_mutiple_strings_with_backslash_backslash_at_end_works_correctly
    tok = initialize_tokenizer( <<-EOD
      "\\\\" "hello"
      EOD
    )
    assert_equal('\\\\', tok.next.token.value)
    assert_equal('hello', tok.next.token.value)
  end

  def test_chars
    tok = initialize_tokenizer( <<-EOD
      'a' 'b'
      EOD
    )
    assert_equal(Token::CHARACTER, tok.next.token.type) 
    assert_equal('a', tok.token.value) 
    assert_equal(Token::CHARACTER, tok.next.token.type) 
    assert_equal('b', tok.token.value) 
  end

  #TODO test correct line number on multiple line quotes
  def test_chars_with_backslash
    tok = initialize_tokenizer( <<-EOD
      '\\''  '\\\\'
      EOD
    )
    assert_equal("\\'", tok.next.token.value) 
    assert_equal('\\\\', tok.next.token.value) 
    assert_equal(Token::CHARACTER, tok.token.type) 
  end

  def test_char_does_not_extend_beyond_a_single_char
    tok = initialize_tokenizer( <<-EOD
      '\\\\' '/'
      EOD
    )
    assert_equal('\\\\', tok.next.token.value) 
    assert_equal('/', tok.next.token.value) 
  end


  def test_identifiers
    tok = initialize_tokenizer( <<-EOD
        _a a8 B8 a_b1
      EOD
    )

    assert_equal('_a', tok.next.token.value) 
    assert_equal(Token::IDENTIFIER, tok.token.type) 
    assert_equal('a8', tok.next.token.value) 
    assert_equal(Token::IDENTIFIER, tok.token.type) 
    assert_equal('B8', tok.next.token.value) 
    assert_equal(Token::IDENTIFIER, tok.token.type) 
    assert_equal('a_b1', tok.next.token.value) 
    assert_equal(Token::IDENTIFIER, tok.token.type) 
  end

  def test_non_identifiers
    tok = initialize_tokenizer( <<-EOD
        8a 
      EOD
    )

    assert_equal('8', tok.next.token.value) 
    assert_equal(Token::NUMBER, tok.token.type) 
    assert_equal('a', tok.next.token.value) 
    assert_equal(Token::IDENTIFIER, tok.token.type) 
  end

  def test_macros
    tok = initialize_tokenizer( 
      <<-EOD
        #ifdef
        #include
      EOD
    )

    assert_equal('#ifdef', tok.next.token.value) 
    assert_equal(Token::DIRECTIVE, tok.token.type) 
    tok.next
    assert_equal('#include', tok.next.token.value) 
  end

  def test_delimiters
    tok = initialize_tokenizer( 
      <<-EOD
        () {}
      EOD
    )

    assert_equal('(', tok.next.token.value) 
    assert_equal(')', tok.next.token.value)
    assert_equal Token::MATCHED_OP, tok.token.type
    assert_equal('{', tok.next.token.value)
    assert_equal('}', tok.next.token.value)
  end

  def test_lt_gt
    tok = initialize_tokenizer( 
      <<-EOD
        <hello>
      EOD
    )
    assert_equal('<', tok.next.token.value)
    assert_equal('hello', tok.next.token.value)
    assert_equal('>', tok.next.token.value)

  end

  def test_cpp_comments 
    tok = initialize_tokenizer( 
      <<-EOD
        A // this is a cpp comment
        B
      EOD
    )

    assert_equal('A', tok.next.token.value)
    assert_equal(Token::CPP_COMMENT, tok.next.token.type)
    assert_equal('this is a cpp comment', tok.token.value)
    assert_equal(Token::EOL, tok.next.token.type)
    assert_equal('B', tok.next.token.value)
  end

  def test_mutiple_c_comments_on_the_same_line
    tok = initialize_tokenizer( 
      <<-EOD
        A /* this is a c comment */ B /* */ C
      EOD
    )

    assert_equal('A', tok.next.token.value)
    assert_equal(Token::C_COMMENT, tok.next.token.type)
    assert_equal('this is a c comment', tok.token.value)
    assert_equal('B', tok.next.token.value)
    assert_equal(Token::C_COMMENT, tok.next.token.type)
    assert_equal('', tok.token.value)
    assert_equal('C', tok.next.token.value)
  end
  
  def test_mutli_lined_c_comments_is_only_one_token
        tok = initialize_tokenizer( 
      <<-EOD
        A /* 
          this is a c comment 
          and another
        */ B
      EOD
    )

    assert_equal('A', tok.next.token.value)
    assert_equal(Token::C_COMMENT, tok.next.token.type)
    assert_equal("this is a c comment\nand another\n", tok.token.value)
    
    assert_equal('B', tok.next.token.value)
  end

  def test_c_comments_some_more
    tok = initialize_tokenizer( 
      <<-EOD
        void fun_c_comment() {
          /* not this
        }
        void fun(string arg) {
          int i=0; */
          if (i == 0) {
            printf("Hello Zero");
          }
        }
      EOD
    )

    tok.next.next.next.next.next.next
    assert_equal("not this\n}\nvoid fun(string arg) {\nint i=0;", tok.next.token.value)
    tok.next
    assert_equal('if', tok.next.token.value)
  end
  
  def test_unending_c_comment_raises_exception
    tok = initialize_tokenizer( <<-EOD
      /*
      EOD
    )
    assert_raise(RuntimeError) { tok.next }
  end

  def test_blank_lines 
    tok = initialize_tokenizer( 
      <<-EOD
        A
        
        B
      EOD
    )

    assert_equal('A', tok.next.token.value)
    assert_equal(Token::EOL, tok.next.token.type)
    assert_equal(Token::EOL, tok.next.token.type)
    assert_equal('B', tok.next.token.value)
  end

  def test_new_line
    tok = initialize_tokenizer(
      <<-EOD
        blah

      EOD
    )

    assert_equal('blah', tok.next.token.value) 
    assert_equal(Token::EOL, tok.next.token.type) 
  end

  def test_new_line_starting_with_c_comment
    tok = initialize_tokenizer(
      <<-EOD
          /* comment this*/

      EOD
    )

    assert_equal('comment this', tok.next.token.value) 
    assert_equal(Token::EOL, tok.next.token.type) 
  end

  def test_unspecified_operators
    tok = initialize_tokenizer(
      <<-EOD
        *  ^ & ? 
      EOD
    )

    assert_equal('*', tok.next.token.value) 
    assert_equal('^', tok.next.token.value) 
    assert_equal('&', tok.next.token.value) 
    assert_equal('?', tok.next.token.value) 
  end

  def test_import_line
    tok = initialize_tokenizer( <<-EOD
       import org.xputah.*; 
      EOD
    )
    tok.next
    tok.next
    assert_equal('.', tok.next.token.value) 
    assert_equal('xputah', tok.next.token.value) 
    assert_equal('.', tok.next.token.value) 
    assert_equal('*', tok.next.token.value) 
    assert_equal(Token::SEMICOLON, tok.next.token.value) 

  end

  def test_multiple_length_operators
    tok = initialize_tokenizer( <<-EOD
        += == != ++ [] || && \\\\
      EOD
    )

    assert_equal('+=', tok.next.token.value) 
    assert_equal('==', tok.next.token.value) 
    assert_equal('!=', tok.next.token.value) 
    assert_equal('++', tok.next.token.value) 
    assert_equal('[]', tok.next.token.value) 
    assert_equal('||', tok.next.token.value) 
    assert_equal('&&', tok.next.token.value) 
    assert_equal('\\', tok.next.token.value) 
    assert_equal('\\', tok.next.token.value) 
    assert_equal(Token::OP, tok.token.type) 
  end

  # TODO what belongs in this test?
  def test_operators_that_dont_belong_together
    tok = initialize_tokenizer( <<-EOD
        +*
      EOD
    )

    assert_equal('+', tok.next.token.value) 
    assert_equal('*', tok.next.token.value) 
  end

  def test_function_declaration
    tok = initialize_tokenizer(
    <<-EOD
    functionName(int blah) { }
    EOD
    )

    assert_equal('functionName', tok.next.token.value) 
    assert_equal('(', tok.next.token.value) 
    assert_equal('int', tok.next.token.value) 
    assert_equal('blah', tok.next.token.value) 
    assert_equal(')', tok.next.token.value) 
  end

  def test_next_returns_nill
    tok = initialize_tokenizer(
    <<-EOD
    oneToken
    EOD
    )

    assert_equal('oneToken', tok.next.token.value) 
    assert_equal(Token::EOL, tok.next.token.type) 
    assert_equal(nil, tok.next) 
  end

  def test_next_previous_tokens
    tok = initialize_tokenizer(
      <<-EOD
        functionName(int blah) { }
      EOD
    )
    tok.next
    assert_equal('functionName', tok.token.value) 
    assert_equal('(', tok.subsequent_token.value) 
    assert_equal(Token::EOL, tok.previous_token.type)
    tok.next
    assert_equal('int', tok.subsequent_token.value) 
    assert_equal('functionName', tok.previous_token.value) 
  end
  
  def test_getting_lines
    tok = initialize_tokenizer(
      <<-EOD
        Line one
        Line two
        Line three
      EOD
    )
    
    lines = tok.lines
    assert_match(/Line two/, lines[1])
    assert_equal(3, lines.length)
  end

  def test_line_num
    tok = initialize_tokenizer(
      <<-EOD
        Line_one
        Line_two
        Line_three
      EOD
    )
    
    assert_equal(1, tok.next.token.line_num)
    assert_equal(1, tok.next.token.line_num)

    assert_equal(2, tok.next.token.line_num)
    tok.next
    tok.next
    assert_equal(3, tok.token.line_num)
  end
  
  def test_line_num_with_comments
    tok = initialize_tokenizer(
      <<-EOD
        Line_one
        /* Line_two
        Line_three 
        */
        // Line five
        Line_six
      EOD
    )
    
    assert_equal(1, tok.next.token.line_num)
    assert_equal(1, tok.next.token.line_num)
    assert_equal(2, tok.next.token.line_num)
    assert_equal(Token::C_COMMENT, tok.token.type)
    assert_equal(Token::EOL, tok.next.token.type)
    assert_equal(4, tok.token.line_num)
    assert_equal(Token::CPP_COMMENT, tok.next.token.type)
    assert_equal(5, tok.token.line_num)
    tok.next
    assert_equal(6, tok.next.token.line_num)
  end

  def test_line_num_multiple_comments_one_line
    tok = initialize_tokenizer(
      <<-EOD
        Line_one /* still one */ still_one  // and still one
        Line_two
      EOD
    )
    
    assert_equal(1, tok.next.token.line_num)
    assert_equal(1, tok.next.token.line_num)
    assert_equal(1, tok.next.token.line_num)
    assert_equal(1, tok.next.token.line_num)
    assert_equal(1, tok.next.token.line_num)
    assert_equal(2, tok.next.token.line_num)
  end  

  def test_line_num_multiple_empty_comment_lines
    tok = initialize_tokenizer(
      <<-EOD
        line_one
        /*


        */
        line_6
      EOD
    )
    
    assert_equal(1, tok.next.token.line_num)
    assert_equal(1, tok.next.token.line_num)
    assert_equal(2, tok.next.token.line_num)
    assert_equal(5, tok.next.token.line_num)
    assert_equal(6, tok.next.token.line_num)
  end

  def test_line_num_starting_with_multilined_comments_returns_begining_of_line
    tok = initialize_tokenizer(
      <<-EOD
        /* starting with a comment

        */
        line_4
      EOD
    )
    
    assert_equal(1, tok.next.token.line_num)
    assert_equal(3, tok.next.token.line_num)
    assert_equal(4, tok.next.token.line_num)
  end

  def test_line_num_with_wrapping_quotes
    tok = initialize_tokenizer(
      <<-EOD
        "line one\\
        two"
        'three\\
        four'
        "five"
      EOD
    )
    
    assert_equal(1, tok.next.token.line_num)
    assert_equal(Token::EOL, tok.next.token.type)
    assert_equal(3, tok.next.token.line_num)
    assert_equal(Token::EOL, tok.next.token.type)
    assert_equal(5, tok.next.token.line_num)
  end

  def test_line_num_wrapping_quotes_mingled_with_wrapping_comments
    tok = initialize_tokenizer(
      <<-EOD
        "line one\\
        two"
        /* three
        four */
        // five
        six
      EOD
    )
    
    assert_equal(1, tok.next.token.line_num)
    assert_equal(Token::EOL, tok.next.token.type)
    assert_equal(3, tok.next.token.line_num)
    assert_equal(Token::EOL, tok.next.token.type)
    assert_equal(5, tok.next.token.line_num)
    assert_equal(Token::EOL, tok.next.token.type)
    assert_equal(6, tok.next.token.line_num)
  end

  #TODO i don't think this is a valid test
  def xxxtest_a_symbol_is_not_an_operator
    tok = initialize_tokenizer( <<-EOD
      #
      EOD
    )
    assert_not_equal(Token::OP, tok.next.token.type)
  end

  def test_anotations
    annotation = "@Annotation"
    tok = initialize_tokenizer( <<-EOD
      #{annotation}
      @ANN@
      EOD
    )
    assert_equal(annotation, tok.next.token.value)
    assert_equal(Token::ANNOTATION, tok.token.type)
    tok.next
    assert_equal('@ANN', tok.next.token.value)
    assert_equal(Token::ANNOTATION, tok.token.type)
    assert_equal('@', tok.next.token.value)
    assert_equal(Token::ANNOTATION, tok.token.type)
  end

  def test_numbers
    tok = initialize_tokenizer( <<-EOD
      42 3.1415 -1 +8
      EOD
    )
    assert_equal(42, tok.next.token.value.to_i)
    assert_equal(Token::NUMBER, tok.token.type)
    assert_equal(3.1415, tok.next.token.value.to_f)
    assert_equal(Token::NUMBER, tok.token.type)
    assert_equal(-1, tok.next.token.value.to_i)
    assert_equal(Token::NUMBER, tok.token.type)
    assert_equal(8, tok.next.token.value.to_i)
    assert_equal(Token::NUMBER, tok.token.type)
    # TODO assert_equal(Token::LITERAL === tok.token.type)
  end
end
