#  Show sorted list of times to run Unit Tests.

require 'rexml/document'

RESULTS_PATH='test_results'
INPUT_FILE='TEST-AllUnitTests.xml'
OUTPUT_PATH="#{RESULTS_PATH}/html/slow.html"

def calculate_color(time)
  return "Red" if time.to_f >= 1.0
  return "Orange" if time.to_f >= 0.5
  return "Yellow" if time.to_f >= 0.1
  return "LightGreen" if time.to_f >= 0.05
  return "Green"
end


times = {}

in_file = File.new("#{RESULTS_PATH}/#{INPUT_FILE}")
out_file = File.new(OUTPUT_PATH, "w+")

doc = REXML::Document.new in_file

doc.elements[1].elements.each { |element|
  if element.name == 'testcase'
    times[element.attributes['name']] = element.attributes['time'] unless element.attributes['time'].to_f < 0.001
  end
}

sorted_times = times.sort { |a,b| b[1].to_f <=> a[1].to_f }

out_file.puts ('<html><head><title>Unit test times</title></head><body><center><H1>Unit Test Running Times:</H1><p><table border="2" cellpadding="5"><tr><td bgcolor="Gray"><b>Seconds</b></td><td bgcolor="Gray"><b>Test Name</b></td></tr>')

sorted_times.each { |item| 
  out_file.print "<tr><td"
  color = calculate_color(item[1])
  out_file.print(" bgcolor=\"#{color}\"")
  out_file.printf(">% 2.3f", item[1])
  out_file.print("</td><td")  
  out_file.print(" bgcolor=\"#{color}\"")
  out_file.print(">#{item[0]}")
}

out_file.puts ("</table></center></body></html>")
