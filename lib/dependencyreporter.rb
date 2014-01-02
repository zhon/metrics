#!/usr/bin/env ruby
#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#


require_relative 'reporter'

class DependencyReporter < Reporter
  def initialize(dependency_collector)
    @max_includes = dependency_collector.result[DependencyCollector::MAX_INCLUDES]
    @total_includes = dependency_collector.result[DependencyCollector::TOTAL_INCLUDES]
    @num_files = dependency_collector.result[DependencyCollector::NUM_FILES]
    @max_file = dependency_collector.result[DependencyCollector::MAX_FILE]
    @includes = dependency_collector.result[DependencyCollector::INCLUDES]
    @cycles = dependency_collector.result[DependencyCollector::CYCLES]
  end

  def summary

    return <<DATA


Dependency Summary:

   Number of cyclical dependencies: #{@cycles.length}
   Most dependencies in a source file: #{@max_includes} (in file: #{@max_file})
   Average dependencies per file: #{average_includes}
DATA
  end

  def details(maximum)
    report = top_dependencies(maximum)
    report << cyclical_dependencies(maximum)
  end

  def create_gnuplot_output(path)
    write_output("#{path}max_depend.dat", @max_includes)
    write_output("#{path}avg_depend.dat", average_includes)
    write_output("#{path}cycles.dat", @cycles.length)
  end

private
  def average_includes
    @num_files = 1 if @num_files == 0
    @total_includes/@num_files.to_f
  end

  def cyclical_dependencies(maximum)
    count = 0

    report = "\n\nCyclical Dependencies: #{'none' if 0==@cycles.length}\n\n"

    @cycles.each { | cycle |
      count += 1
      break if count > maximum
      report << "   #{cycle.join(' -> ')}\n\n"
    }

    return report + "\n"
  end

  def traverse(file_name, depth)
    @path.push(file_name)

    if 2 == @path.grep(file_name).length
      if @path[-1] == @path[0]
        @cycles.push @path.clone
      end

      @path.pop
      return
    end

    if @includes[file_name]
      @includes[file_name].sort.each { | next_file |
        traverse(next_file, depth+1)
      }
    end

    @path.pop
  end

  def top_dependencies(maximum)
    count = 0
    report = "\n\nTop #{maximum} Files with Most Dependencies\n\n"
    @includes.sort{|a,b| b[1].length <=> a[1].length
            }.each { |file_name,includes |

      report += <<-DATA

   #{ file_name } (#{includes.length} dependencies)
      #{ includes.sort.join("\n      ") }
      DATA

      count += 1
      break if maximum == count
    }
    return report
  end
end
