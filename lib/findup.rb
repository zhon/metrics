#!/usr/bin/env ruby
#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#



require "find"
require "excludes"
require "datestamp"

$worst_percent = 0

#  Primary class, scans files for duplicated lines
class FinDup
  
#  Constructor method ------------------------------------------------------

  def initialize(startDir, commonLines)
    @startDir = startDir
    @commonLines = commonLines
    @scoreMap = {}
  end
  
#  Accessor Methods ---------------------------------------------------------  

  def getStartDir
    @startDir
  end
  
  
#----------------------------------------------------------------------------  
  
  def BlankOrCommonLine(s)
    @commonLines.each{|l|
      if l == s.strip
        return true
      end # if  clause
    } # close l iteration
    return false
  end #  BlankOrCommonLine method
  
#----------------------------------------------------------------------------  
  
  def findAllIdenticalLines(lineNum, lines)
    matchLineNum = 0
    matchString = lines[lineNum - 1]
    identicalLines = Array.new

    lines.each { |l|
      matchLineNum = matchLineNum + 1
      if matchLineNum > lineNum
        if (l == matchString)
          identicalLines << matchLineNum
        end #  if equal block
      end # if lineNum block
    } # close l iteration
    
    return identicalLines
    
  end #  findAllIdenticalLines method
  
#----------------------------------------------------------------------------  
  
  def checkDups(fName)
  
    lineNum = 0
    lineMap = Hash.new
    totalDuplicatedLines = 0
    
    f = File.new(fName, "r")
    lines = f.readlines()
    lines.each{ |l|
      lineNum = lineNum + 1
      if BlankOrCommonLine(l.strip) == false
        if not lineMap.has_key?(l)
          lineArray = findAllIdenticalLines(lineNum, lines)
          if lineArray.length > 0
            totalDuplicatedLines = totalDuplicatedLines + lineArray.length
            lineMap[l] = [lineNum] + lineArray
          end #  if array empty
        end # if has_key
      end # if blankOrCommon    
    } # close l iteration

    if totalDuplicatedLines > 0
      percentDups = Integer(((totalDuplicatedLines + 0.0001) / (lines.length + 0.0001)) * 100.0)
      @scoreMap[fName] = percentDups
      STDERR.printf("File %d:  %s\n", @scoreMap.length, fName)
    else
      STDERR.printf("Skipping: %s (no duplication)\n", fName);
    end  #  if has duplicated lines clause
    
    return lineMap    
  end #  checkDups method
  
#----------------------------------------------------------------------------  

  def printOutResults(files, maximum)

    puts
    puts "Top #{maximum} Files With Internal Duplication:"
    puts
    
    count = 0
    worstFilesFirst = @scoreMap.sort{|a,b| b[1] <=> a[1]}
    $worst_percent = worstFilesFirst[0][1] 
    worstFilesFirst.each{|i|
      count += 1
      break if count > maximum
      f = i[0]
      uniqueDups = files[f].length
      if (uniqueDups > 0)
        puts
        puts "-----------------------------------------------------------------------------"
        puts "File:  " + f
        puts "Proportion of duplicated lines in file:  " + String(i[1]) + "%"
        puts "Number of unique duplicated lines:  " + String(files[f].length)
        puts "-----------------------------------------------------------------------------"
        puts
        dupArray = files[f].sort { |a,b| b[1].length <=> a[1].length }
        dupArray.each {|d|
          printf("  The line:  \"%s\"\n", d[0].chop)
          printf("  Is duplicated %d times on the following lines:", d[1].length)
          d[1].each {|l|
            printf("  %d", l)
          } # each line duplicated block
          puts
          puts
        } # each unique duplicate block 
      end #   if uniqueDups clause
    } #  each file block
  end #  printOutResults method

#----------------------------------------------------------------------------  
  
  def searchForDuplicateLines()
    exclude = Excludes.new
    filesChecked = Hash.new
    Find.find(@startDir) do |f|
      Find.prune if exclude.file?(f)
      next unless f =~ %r{\.(?:(?:[ch](?:pp)*$)|(?:java$))}
        filesChecked.store(f,checkDups(f))
    end #  Find block
    
    return filesChecked  
  end #  SearchForDuplicateLines method
  
end #  FinDup class


  def write_gnuplot_output(file_path, data)
    lines_file = File.new("#{file_path}/indup.dat", 'a+');
    lines_file.puts("#{Datestamp.fractional_month(Time.new)}\t#{data}");
    lines_file.close();
  end


#----------------------------------------------------------------------------  
#  MAIN PROGRAM:
#----------------------------------------------------------------------------

commonSingleLines = ["", "return;", "try", "try{", "else", "else{", "break;", "finally",
          "#else", "#endif", "{", "}", 
          "//", "/*", "*/","/**", "**", "**/", "/***", "***/", "*"]

if (ARGV.length < 1)
  path = '.'
else
  path = ARGV[0]
end
 
finder = FinDup.new(path, commonSingleLines)

STDERR.puts
STDERR.puts
STDERR.puts "Please Wait... scanning " + finder.getStartDir + " for all code files."
STDERR.puts
STDERR.puts

results = finder.searchForDuplicateLines()
finder.printOutResults(results, 50)

write_gnuplot_output(ARGV[1], $worst_percent) if ARGV.length==2
