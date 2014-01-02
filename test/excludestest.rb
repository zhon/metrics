#!/usr/bin/env ruby
#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#



require 'helper'

require 'excludes'

class ExcludesTest < Test::Unit::TestCase
  def setup; set_up end;  # because of stupid Test::Unit changes
  def set_up
    @ex = Excludes.new
  end

  def test_files
      # TODO test excluded files
    end

  def test_files_not_in_list
    assert_equal(false, @ex.file?('something else'))
  end

  def test_lines
    assert @ex.line?('try')
    assert @ex.line?('else')
    assert @ex.line?('finally')
    assert @ex.line?('{')
    assert @ex.line?('}')
    assert @ex.line?(';')
  end

  def test_line_with_comments
    assert @ex.line?('////////////////////////////////////////////////////')
    assert @ex.line?('/* this something else')
    assert @ex.line?('/* do not remove */ /* more stuff */')
    assert @ex.line?('* this can only be comment. if not oh well')
    assert @ex.line?(' ** Get information')
  end

  def test_line_with_comments_and_code_we_need
    assert_equal(false, @ex.line?('int i = 0;  // initialize i to zero'))
    assert_equal(false, @ex.line?('hello /* this something else'))
    assert_equal(false, @ex.line?('/* do not remove */ i = i;'))
    assert_equal(false, @ex.line?('/* do not remove */ i = i; /* this */'))
    assert_equal(false, @ex.line?('*option'))
  end

  def test_lines_not_excluded
    assert_equal(false, @ex.line?('int myVariable;'))
  end
end
