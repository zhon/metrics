#!/usr/bin/env ruby
#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2005.  All rights reserved.
#

class TokenType
  include Comparable
  def <=>(other)  self.class <=> other.class end
  def ===(other)  is_a?(other.is_a?(Class) ? other : other.class) end
  def hash()      self.class.hash end
  def to_s()      self.class.to_s end
end

class Identifier < TokenType; end
class Annotation < Identifier; end

class Directive < TokenType; end
class Eol < TokenType; end
class Op < TokenType; end             # ! @ # $ % ^ & * 

class Literal < TokenType; end
class StringLiteral < Literal; end
class Character < Literal; end  
class Number < Literal; end

class Semicolon < TokenType; end
