#!/usr/bin/env ruby
#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#


require 'find'
require 'reporter'

# NOTE:  For this to work properly, you have to have:
#    1.  importcleaner.jar in the current directory
#    2.  The *.class files in the same directory as the *.java files.
#
#    The file import.dat needs to have GNUPLOT data generated for total imports

class ImportReporter < Reporter

  def write_out(path, data)
    write_output(path,data)
  end  

end


unnecessary = 0

if ARGV[0] == nil
  puts
  puts 'USAGE:  imports.rb [start directory for .java/.class files]'
  puts
  exit
end

Find.find(ARGV[0]) do |filename|
    Find.prune if filename == "."
    if /\.java$/ =~ filename
    $stderr.puts "#{filename}\n"

    class_file = filename.sub(/\.java/, '.class')
    if not FileTest.exists?(class_file)
      puts 'ERROR!  File does not exist:  ' + class_file
      puts
      next
    end
    
    package = ''
    source_imports = []
    
    source = File.new(filename)
    source.each_line { | line |
              package = ((line.sub('package ', '')).sub(';', '')).strip if line =~ '^package'
              source_imports.push(line.strip) if line =~ '^import'    
             }
             
    system "java -jar importcleaner.jar #{filename} > temp.txt"
    
    imports = File.new ("temp.txt")
    import_lines = imports.readlines
    import_lines.delete_if {|import| Regexp.new(package) =~ import }
    
    
    difference = source_imports.size - import_lines.size
    if difference > 0
      unnecessary += difference
    
      puts "Unnecessary imports in file:  #{filename} (#{difference} total)"
      puts "Source file has #{source_imports.size} imports, recommend #{import_lines.size}"
      puts "SOURCE IMPORTS: "
      puts source_imports
      puts "RECOMMENDED IMPORTS: "
      puts import_lines
      puts
    end
  end
end

puts
puts "TOTAL UNNECESSARY IMPORTS IN ALL FILES:  #{unnecessary}"

ImportReporter.new.write_out('imports.dat',unnecessary)

