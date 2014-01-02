#!/usr/bin/env ruby
#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#

require 'helper'

require 'fileparser'


class FileParserTest < Test::Unit::TestCase
  FILENAME = 'file-parser-test.remove'

  def initialize_length(data)
    file = File.new(FILENAME, "w+")
    file.print data
    file.close
    return FileParser.new(FILENAME)
  end

  def test_single_function
    length = initialize_length(
      <<-EOD
        void fun(string arg)
        {
          i = i++
        }
      EOD
    )

    assert_equal(4, length.counts['fun'])
  end

  def test_single_function_one_line_func
    length = initialize_length(
      <<-EOD
        void fun_one_line_func(string arg) {
          i = i++
        }
      EOD
    )
    assert_equal(3, length.counts['fun_one_line_func'])
  end

  def test_nested_braces
    length = initialize_length(
      <<-EOD
        void fun_nested_braces(string arg) {
          int i = 0;
          if (i == 0) {
            printf("Hello Zero");
          }
        }
      EOD
    )
    assert_equal(6, length.counts['fun_nested_braces'])
  end

  def test_cplusplus_comment
    # TODO handle blocks of cpp comments as a single comment
    length = initialize_length(
      <<-EOD
      void fun_cpp_comment(string arg) {
        i = i++;
    //  }
    //  void fun(string arg) { 
    //    int i = 0;
        if (i == 0) { // comment
          printf("Hello Zero");
        }
      }
    EOD
    )
    assert_equal(6, length.counts['fun_cpp_comment'])
    assert_equal(4, length.counts['comment'])

    assert_equal(4, length.comments.count)
    assert_equal('}', length.comments[0].to_s)
  end

  def test_c_comment
    length = initialize_length(
      <<-EOD
      void fun_c_comment(string arg) {
        i = i++; 
        /* not this
      }
      void fun(string arg) {
        int i = 0; */
        if (i == 0) {
          printf("Hello Zero");
        }
      }
    EOD
    )
    assert_equal(6, length.counts['fun_c_comment'])

    assert_equal(1, length.comments.count)
    assert_equal(4, length.comments[0].line_count)
  end

  def test_c_comment_with_stuff_on_line
    length = initialize_length(
      <<-EOD
      void fun_c_comment(string arg) {
        i = i++; /*  not this
      }
      void fun(string arg) {
      barf  */  int i = 0;
        if (i == 0) {
          printf("Hello Zero");
        }
      }
    EOD
    )
    assert_equal(1, length.comments.count)
    assert_equal(4, length.comments[0].line_count)
    assert_equal("not this\n}\nvoid fun(string arg) {\nbarf", length.comments[0].to_s)
    assert_equal(6, length.counts['fun_c_comment'])
  end

  def test_one_line_c_comment
    length = initialize_length(
      <<-EOD
      void fun_one_line_c_comment(string arg) {
        /*  i = */ i++ /* stuff */;
      }
    EOD
    )
    assert_equal(3, length.counts['fun_one_line_c_comment'])
  end

  def test_multiple_functions
    length = initialize_length(
      <<-EOD
        void fun1(string arg) {
          i = i++;
        }
        void fun2(string arg)
        {
          int i = 0;
          if (i == 0) {
            printf("Hello Zero");
          }
        }
      EOD
    )
    function_length = length.counts
    assert_equal(3, function_length["fun1"])
    assert_equal(7, function_length["fun2"])
  end
  
  # TODO implement function overloading
  def xxxtest_overloaded_functions
    length = initialize_length(
      <<-EOD
         void fun1(integer arg) {
           i = i++;
         }
         void fun1(string arg)
         {
           int i = 0;
           if (i == 0) {
             printf("Hello Zero");
           }
         }
       EOD
     )
     function_length = length.counts
     assert_equal(7, function_length["fun1"])
   end

  def test_multi_line_func_decl
    length = initialize_length(
      <<-EOD
      void fun_multi_line_func_decl(string arg, garbage man,
                int(foo *)bar,
                more garbage
                )
      {
        printf ("Hello C");
      }
    EOD
    )
    assert_equal(7, length.counts['fun_multi_line_func_decl'])
  end
  
  def test_global_lines_outside_functions
    length = initialize_length(
      <<-EOD
      #include "foobar.h"
      void fun_multi_line_func_decl(string arg, garbage man,
                int(foo *)bar,
                more garbage
                )
      {
        printf ("Hello C");
      }
      #include "something else"
    EOD
    )
    assert_equal(2, length.counts['global'])
  end

  def test_blank_lines
    length = initialize_length(
      <<-EOD
      #include "foobar.h"
    
      void fun_blank_lines(string arg, 
      
                garbage man)
      {
      
        printf ("Hello C");
      }
      
    EOD
    )
    assert_equal(1, length.counts['global'])
    assert_equal(5, length.counts['fun_blank_lines'])
  end

  def test_commented_out_global_code_is_not_global
    length = initialize_length(
      <<-EOD
      #include "foobar.h"
      
      /*
      extern "C" {
      #include "barfoo.h"
      }

      func () { } this function is dead code 
      */

      func (foo bar) {
      }
    EOD
    )
    assert_equal(1, length.counts['global'])
  end

  def test_extern_counts_as_global
    length = initialize_length(
      <<-EOD
      #include "foobar.h"
      
      extern "C" {
      #include "barfoo.h"
      }
    EOD
    )
    assert_equal(4, length.counts['global'])
  end

  def test_counting_comment_lines
    length = initialize_length(
      <<-EOD
      #include "foobar.h"
      /*   comment line 1
        comment line 2
       err 3 */


      func () { 
        int i = i++; /* 3 what is this */
      }  // comment 4: this function is dead code 
    EOD
    )
    assert_equal(5, length.counts['comment'])
  end

  def test_counting_lines_with_curlies_on_same_line
    length = initialize_length(
      <<-EOD
      curlies_on_same_line() {
        if (1) { 
        } else { }
      } 
    EOD
    )
    assert_equal(4, length.counts['curlies_on_same_line'])
  end

  def test_counting_lines_with_curlies_with_else
    length = initialize_length(
      <<-EOD
      curlies_on_same_line() {
        if (1) { 
        } else { 
        } else { 
        }
      } 
    EOD
    )
    assert_equal(6, length.counts['curlies_on_same_line'])
  end

  def test_function_prototype
    length = initialize_length(
      <<-EOD
      func_prototype();
      another_func_prototype();
    EOD
    )
    assert_equal(nil, length.counts['func_prototype'])
    assert_equal(2, length.counts['global'])
  end
  
  # TODO future enhancement:  support multi-line function prototypes
  def xxxtest_function_prototype_on_more_than_one_line
    length = initialize_length(
      <<-EOD
      func_prototype(
        int myCat,
        boolean huh
      );
    EOD
    )
    assert_equal(nil, length.counts['func_prototype'])
    assert_equal(5, length.counts['global'])
  end

  def test_if_defined
    length = initialize_length(
      <<-EOD
      #if defined(WIN32)
      void
      function()
      {
        cout << "code";
      }
    EOD
    )
    assert_equal(4, length.counts['function'])
  end

  def test_pound_if_0_is_dead_code
    length = initialize_length(
      <<-EOD
      foo bar;
      
      #if 0
      void
      function()
      {
        cout << "code";
      }
      #endif

      #if 0
      foo bar;
      #endif
      
    EOD
    )
    assert_equal(3, length.dead_code_line_numbers[0])
    assert_equal(11, length.dead_code_line_numbers[1])
  end

  def test_dead_code_in_comment
    parser = initialize_length(
      <<-EOD
        /* int someDeadCode; */
        int i = not_dead_code;
        /* Here comes
        int even_more_dead_code;
        */
      EOD
    )
    
    assert_equal 1, parser.dead_code_line_numbers[0]
    assert_equal 3, parser.dead_code_line_numbers[1]
  end

  def test_dead_code_in_comment_as_a_block
    parser = initialize_length(
      <<-EOD
        /* int someDeadCode; */
        int i;
        /*
          dead_code();
        
          int even_more_dead_code;
          int and_even_more_dead_code;
        */
      EOD
    )
    
    assert_equal 1, parser.dead_code_line_numbers[0]
    assert_equal 3, parser.dead_code_line_numbers[1]
    assert_equal 2, parser.dead_code_line_numbers.length
  end

  def test_dead_code_in_cpp_comment
    parser = initialize_length(
      <<-EOD
        // int someDeadCode; 
        int i;
        // dead_code();
        // more_dead_code();
      EOD
    )
    
    assert_equal 1, parser.dead_code_line_numbers[0]
    assert_equal 3, parser.dead_code_line_numbers[1]
    assert_equal 2, parser.dead_code_line_numbers.length
  end

  def test_functions_called
    parser = initialize_length(
      <<-EOD

      int func() { stuff(); }
      
      int main() {
        func();
        func(1, 2, 3);
      }  
      EOD
    )
    
    assert_equal 2, parser.functions()['func']['call_count']
    assert_equal 1, parser.functions['func']['declaration']
  end

  def test_functions_called
    parser = initialize_length(
      <<-EOD
            class testvirtualclass
            {
                virtual purevirtualfunction(int )=0;
            };

            void shouldgetthisfunction(void)
            {
                int i = 0;
                printf ("hi");
            }
      EOD
    )

    refute_nil parser.functions['shouldgetthisfunction']
    assert_equal 1, parser.functions['purevirtualfunction']['declaration']
  end

  def test_functions_with_no_calls_or_declarations
    parser = initialize_length(
      <<-EOD
      int func_nocalls() { stuff(); }

      int main() {
        func_nodef();
      }  
      EOD
    )
    
    assert_equal 0, parser.functions()['func_nocalls']['call_count']
    assert_equal 0, parser.functions['func_nodef']['declaration']
  end
  
  def test_include_with_double_quotes
    parser = initialize_length( <<-EOD
      #include "foo.h"
      #include "sys\\arpa.h"
      #include "sys/ip.h"
      EOD
    )
    assert_equal 'foo.h', parser.includes[0]
    assert_equal 'arpa.h', parser.includes[1]
    assert_equal 'ip.h', parser.includes[2]
  end

  def test_includes
    parser = initialize_length( <<-EOD
      #include <bar.hpp>
      #include <sys/socket.h>
      #include <sys\\host.h>
    
      /*
      #include "not_this.h"
      */
      #include <../yes/this.h>
      #include 'and_this.h'

      EOD
    )
    
    assert_equal 'bar.hpp', parser.includes[0]
    assert_equal 'socket.h', parser.includes[1]
    assert_equal 'host.h', parser.includes[2]
    assert_equal 'this.h', parser.includes[3]
    assert_equal 'and_this.h', parser.includes[4]
    assert_equal 5, parser.includes.length
  end

  def test_includes_no_end
    parser = initialize_length(
      <<-EOD
            #include _some_thing_defined
      EOD
    )
    assert_equal '_some_thing_defined', parser.includes[0]
  end
    
  def test_no_includes
    parser = initialize_length(
      <<-EOD
      /*
      #include "not_this.h"
      */
      EOD
    )
    
    assert_equal 0, parser.includes.length
  end

  def test_include_with_comment_in_between_include_and_literal
    parser = initialize_length( <<-EOD
      #include /* why put comment here */ "o.h"
      #include /* why put comment here */ <my>
      EOD
    )
    
    assert_equal "o.h", parser.includes[0]
    assert_equal "my", parser.includes[1]
  end

  def test_include_with_two_comment_in_between_include_and_literal
    parser = initialize_length( <<-EOD
      #include /* why put comment here? */ /* stupid! */ "o.h"
      EOD
    )
    
    assert_equal 1, parser.includes.length
    assert_equal 2, parser.comments.length
  end

  def test_conditional_logic
    parser = initialize_length(
      <<-EOD
      int foo() {
      switch (c) {
        case 'a':
        case 'b':
        case 'c':
        default:
      }
      
      }
      
      int bar() {
        if 1
          printf;
        else if 0
          dont_printf;
        else
          do_nothing();
      }
      EOD
    )
    
    assert_equal 1, parser.conditionals['foo'][FileParser::SWITCH]
    assert_equal 4, parser.conditionals['foo'][FileParser::CASE]
    assert_equal 4, parser.conditionals['bar'][FileParser::IF]
  end

  def test_gather_literals
    parser = initialize_length(
      <<-EOD
          System.out.println("Hello world");
          String someVar = "Hello world";
      EOD
     )
    assert_equal 2, parser.literals.length
  end

  def test_gather_imports
    parser = initialize_length(
      <<-EOD
        import some.class.path.Blah;
        import some.other.class.path.Blah;
        import java.io.*;
      EOD
     )
    assert_equal 3, parser.imports.length
    assert_equal 'some.class.path.Blah', parser.imports[0]
    assert_equal 0, parser.literals.length, "imports are not literals"
  end

end
