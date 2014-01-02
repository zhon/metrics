

guard :minitest, include: ['lib'], test_file_patterns: '*test.rb' do

  watch(%r|^test/(.*)test\.rb|)
  watch(%r|^lib/(.*?)([^/\\]+)\.rb|)     { |m| "test/#{m[2]}test.rb" }
  watch(%r|^test/helper\.rb|)            { "test" }
end
