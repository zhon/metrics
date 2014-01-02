#!/usr/bin/env ruby

require 'helper'
require 'consoleview'

class ConsoleViewTest < Test::Unit::TestCase

  def set_up
  end

  def test_puts
    view = ConsoleView.new
    view.puts("foo")
  end

end
