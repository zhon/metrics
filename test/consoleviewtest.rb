#!/usr/bin/env ruby

require 'test/unit'
require 'consoleview'

class ConsoleViewTest < Test::Unit::TestCase

  def set_up
  end
  
  def test_puts
    view = ConsoleView.new
    view.puts("foo")
  end

end
