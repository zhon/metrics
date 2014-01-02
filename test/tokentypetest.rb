#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2005.  All rights reserved.
#

require 'helper'

require 'tokentype'

class TokenTypeTest < Test::Unit::TestCase
  def test_comparing_tokens
    t1 = TokenType.new
    t2 = TokenType.new
    assert t1 === t2
    assert t1.hash == t2.hash
    assert_equal t1, t2
    assert_equal 0, t1 <=> t2
  end

  def test_to_s_resturn_class
    assert_equal 'TokenType', TokenType.new.to_s
  end

  def test_identifier_is_a_token_type
    assert Identifier.new === TokenType.new
  end

  def test_annotation_is_an_identifier
    assert Annotation.new === Identifier.new
    assert Annotation.new === Identifier
  end

  def test_single_token_types
    assert Directive.new === TokenType
    assert Eol.new === TokenType
    assert Op.new === TokenType
    assert Character.new === TokenType
  end
end
