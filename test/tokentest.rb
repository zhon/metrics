#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2005.  All rights reserved.
#

require 'helper'

require 'token'

class TokenTest < Test::Unit::TestCase
  def test_const_are_added_with_object_as_their_value
    assert_equal String, Token::STRING.class
  end

  def test_adding_const_raise_exception_if_class_doesnt_exist
    assert_raises(RuntimeError) { Token::BLAH }
  end

  def test_const_to_object_mapping
    assert_equal StringLiteral, Token::STRING_LITERAL.class
  end
end
