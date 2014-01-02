#!/usr/bin/env ruby
#
#  Duplicate  file finder
#  Copyright (c) XPUtah (Jeff Grover) 2000-2002.  All rights reserved.
#



# Calculates what directories or files are using up the most disk space

# Bug in UNIX version of 'find' = if you don't have permissions to open
# a visited directory, it will quit by raising an exception. You can 
# use "findfault" (fault-tolerant find) to catch the exception, and
# avoid this behavior... (or just login as root with the original "find"!)

require_relative 'find'       #use standard old "find" with the above problem
#require_relative 'findfault'   #use fault-tolerant version of "find"

if $0 == __FILE__

  start = Time.new
  
  if ARGV.length < 1
    puts "\nUsage:  dupfiles start_directory\n\n"
    puts "\n"
  else
    files = {}
    
    puts "\n\nDuplicate File Finder Utility:\n\n"
    STDERR.puts
    STDERR.print "Processing ..."
    count = 0
    
    Find.find(ARGV[0]) { |path_name|
      next if File.directory?(path_name)
      
      file = path_name.gsub(/.*?\//, '')
      directory = path_name.sub(Regexp.escape(file), '')
      
      count += 1
      STDERR.print  "." if count % 100 == 0    

      files[file] = [] if files[file] == nil
      begin
        files[file].push(directory)
      rescue # just don't count it if it dies
      end
    }
    
    STDERR.puts "\n\n"
    
    count = 0
    files.sort{ |a, b| b[1].size <=> a[1].size }.each { | file, dir_array |
      count += 1
      break if dir_array.size <= 1
      puts
      puts "#{file} is duplicated in directories:"
      print "\t"
      puts dir_array.join("\n\t") 
    }
    
    STDERR.puts"\n\nProcessing took:  #{Time.new - start} seconds.\n\n"
  end
end
