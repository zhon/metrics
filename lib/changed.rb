system'p4 have ... > have.txt'

files = Array.new
current_path = Dir.pwd
if (File::SEPARATOR == '\\')
  current_path.gsub!(%r{/}, '\\')
  current_path.sub!(/C:/, 'c:')
end

IO.foreach('have.txt') do |line|
  line =~ /.*#(\d+) - (.*)/
  count = $1.to_i
  filename = $2
  filename.sub!(Regexp.escape(current_path), '.')
  files.push([count, filename]) if count > 5
end

files.sort { |a, b| b[0] <=> a[0] }.each do |item|
  puts "#{item[0]}: #{item[1]}"
end

