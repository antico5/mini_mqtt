task :default => :test

task :test do
  $:.unshift File.join( __FILE__, "..", "test" )
  Dir.glob('./test/*test.rb').each { |file| require file }
end
