#!/bin/env ruby

# Dormant test code finder (finds tests not being run as part of a suite)

# TODO:    find "xxx" tests (public void followed by something not starting with test)
#      Handle commented-out tests in the test suite

require 'find'

class UnitTestClasses
  @suite_files
  @source_path
  @suite_tests
  
  def find(source_path, suite_files)
    @suite_files = suite_files
    @source_path = source_path
    @suite_tests = []
    suite_files.each { |file|
      read_suite_tests(file)
    }
    test_files = find_test_files(source_path)
    print_difference(@suite_tests, test_files)
  end
  
  def find_test_files(source_path)
    files = {}
    Find.find(source_path) { |path_name|
      next if File.directory?(path_name)
      file = path_name.gsub(/.*?\//, '')
      next unless file =~ /.*Test.java/
      files[file.gsub(/\.java/,'').chomp] = path_name
    }
    return files
  end
  
  def read_suite_tests(suite_file)
    tests = []
    suite = File.new(suite_file, "r")
    suite.each_line { |line|
      if line =~ /\.suite\(\)/
        suite_name = line.sub(/\.suite.*$/, '')
        suite_name.reverse!
        suite_name.sub!(/\(.*/, '')
        suite_name.reverse!.chomp!
        puts
        puts "NOTE: #{suite_file} runs suite:  #{suite_name}" 
      elsif line =~ /addTest/
        test_name = line.sub(/\.class.*$/, '')
        test_name.reverse!
        test_name.sub!(/\..*/, '')
        test_name.reverse!
        @suite_tests.push(test_name.chomp)
      end
    }
  end
  
  def print_difference(suite_tests, test_files)
    count = 0
    puts
    puts
    puts "FOUND #{test_files.size} TOTAL TEST FILES IN DIRECTORIES UNDER #{@source_path}"
    puts "FOUND #{suite_tests.size} TOTAL TEST CLASSES INCLUDED IN THE FOLLOWING #{@suite_files.size} TEST SUITE FILE(S)"
    print "\t- "
    puts @suite_files.join("\n\t- ")
    puts
    puts
    puts "THE FOLLOWING FILES WERE NOT FOUND IN ANY THE ABOVE #{@suite_files.size} SUITE(S):"
    puts
    test_files.each_key { |file|
      if not suite_tests.include?(file)
        puts test_files[file]
        count += 1 
      end
    }
    puts
    puts "TOTAL NOT FOUND:  #{count}"
    puts
  end

end

# Main program for finding tests not being run:

def usage
  puts
  puts "Finds unused tests not included in the specified test suite file(s):"
  puts "(ASSUMES TEST CLASS FILE NAMING CONVENTION *Test.java AND *.class IN SUITE)"
  puts
  puts
  puts "USAGE:  ruby findtests.rb"
  puts "                     Show this usage description text."
  puts
  puts "        ruby findtests.rb source_path suite_file [suite_file suite_file ...]"
  puts "                     Ensures all tests found in source_path run in suite_file"
  puts
end


if $0 == __FILE__
    
  if ARGV.size < 2
    usage
  else
    UnitTestClasses.new.find(ARGV[0], ARGV[1..-1])    
  end
end
