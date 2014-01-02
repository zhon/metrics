#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2005.  All rights reserved.
#

require 'filewalker'

require 'test/unit'

require 'tmpdir'
require 'find'


class FileWalkerTest < Test::Unit::TestCase
  INCLUDE_GLOBS = %w(*)

  def setup
    @start_dir = Dir.tmpdir + '/test'
    @sub_dir = @start_dir + '/test2'
    Dir.mkdir(@start_dir)
    Dir.mkdir(@sub_dir)

    @file1 = "a_file"
    @file2 = "b_file"
    File.new(@start_dir + '/' + @file1, 'w').close
    File.new(@start_dir + '/' + @file2, 'w').close

    File.new(@sub_dir + '/' + @file1, 'w').close
    File.new(@sub_dir + '/' + @file2, 'w').close
    @processed = []
  end

  def teardown
    dirs = []
    Find.find(@start_dir) do |file|
      if File.directory?(file)
        dirs.push file
      else
        File.delete(file)
      end
    end
    while !dirs.empty?
      Dir.delete(dirs.pop)
    end
  end

  def test_files_processed
    walker = FileWalker.new(@start_dir)
    walker.walk { |file| @processed.push file }
    assert_equal 4, @processed.size
    @processed.sort!
    assert_match %r/[^2].#{@file1}/, @processed[0]
    assert_match %r/[^2].#{@file2}/, @processed[1]
    assert_match %r/2.#{@file1}/, @processed[2]
    assert_match %r/2.#{@file2}/, @processed[3]
  end

  def test_exclude_globs
    exclude_globs = %w(a*)
    walker = FileWalker.new(@start_dir, INCLUDE_GLOBS, exclude_globs)
    walker.walk { |file| @processed.push file }
    @processed.sort!
    assert_equal 2, @processed.size
    assert_match %r/[^2].#{@file2}/, @processed[0]
    assert_match %r/2.#{@file2}/, @processed[1]
  end

  def test_excluded_dir
    exclude_globs = ['*2']
    walker = FileWalker.new(@start_dir, INCLUDE_GLOBS, exclude_globs)
    walker.walk { |file| @processed.push file }
    @processed.sort!
    assert_match %r/[^2].#{@file1}/, @processed[0]
    assert_match %r/[^2].#{@file2}/, @processed[1]
    assert_equal 2, @processed.size
  end

  def test_globed_files
    globs = %w(b*)

    walker = FileWalker.new(@start_dir, globs)
    walker.walk { |file| @processed.push file }
    @processed.sort!
    assert_equal 2, @processed.size
    assert_match %r/[^2].#{@file2}/, @processed[0]
    assert_match %r/2.#{@file2}/, @processed[1]
  end

end
