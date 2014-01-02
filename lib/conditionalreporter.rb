#
#  C/C++/Java (and C#?) Extreme Code Metrics program
#  Copyright (c) XPUtah (Jeff Grover and Zhon Johansen) 2000-2002.  All rights reserved.
#


require_relative 'reporter'

class ConditionalReporter < Reporter

  def initialize(conditionalcollector)
    @max_switch = conditionalcollector.result[ConditionalCollector::MAX_SWITCH]
    @max_case = conditionalcollector.result[ConditionalCollector::MAX_CASE]
    @max_if = conditionalcollector.result[ConditionalCollector::MAX_IF]
  	@conditionals = conditionalcollector.result[ConditionalCollector::CONDS]
  end

  def summary
  
"
Conditional Logic Summary:

   Most 'switch' statements: #{@max_switch[0]}  (#{@max_switch[1]}() in #{@max_switch[2]})
   Most cases: #{@max_case[0]}  (#{@max_case[1]}() in #{@max_case[2]})
   Most if/else conditions: #{@max_if[0]}  (#{@max_if[1]}() in #{@max_if[2]})

"
  end

  def details(maximum)
  	output = ""
  	output << "\n\nFiles With Most Conditionals:\n\n"
  	
    count = 0
  	@conditionals.sort{ |a, b| b[1] <=> a[1]}.each do |item|
      break if count == maximum
      count += 1

  		output << "   #{item[1].to_s} #{item[0]}\n"
    end
  	output
  end

  def create_gnuplot_output(path)
    write_output("#{path}switch.dat", @max_switch[0])
    write_output("#{path}case.dat", @max_case[0])
    write_output("#{path}if.dat", @max_if[0])
  end
end
