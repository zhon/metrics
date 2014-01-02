
require 'reporter'

class LiteralReporter < Reporter

  def initialize(collector)
    @literals = collector.result[LiteralCollector::LITERALS]
    @total_literals = collector.result[LiteralCollector::TOTAL_LITERALS]
  end

  def summary

    return <<-EOD

Literals Summary:

   Total Literals: #{@total_literals}
   Total Unique Literals: #{@literals.length}
   Total Duplicate Literals: #{@total_literals - @literals.length}
    EOD
  end

  def details(max)
    details = "\nTop #{max} Duplicated Constants:\n\n"

    count =0
    sort_by_occurance().each do |name, value|
      break if count == max
      count += 1
      total = value.values.flatten.size
      details << "The literal '#{name}' occurs #{total} total times in\n"
      value.each do |name, value|
        details << "    #{name} at line(s) #{value.join(' ')}\n"
      end
      details << "\n"
    end
    return details
  end

  def create_gnuplot_output(path)
      write_output("#{path}literal.dat", @total_literals)
      write_output("#{path}literal-dup.dat", @total_literals - @literals.length)
  end

  def sort_by_occurance
    @literals.sort {|a,b| b[1].to_a.flatten.length <=> a[1].to_a.flatten.length}
  end
end


