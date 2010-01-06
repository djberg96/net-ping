########################################################################
# example_pinghttp.rb
#
# A short sample program demonstrating an http ping. You can run
# this program via the example:http task. Modify as you see fit.
########################################################################
require 'net/ping'

good = 'http://www.google.com/index.html'
bad  = 'http://www.ruby-lang.org/index.html'

puts "== Good ping, no redirect"

p1 = Net::Ping::HTTP.new(good)
p p1.ping?

puts "== Bad ping"

p2 = Net::Ping::HTTP.new(bad)
p p2.ping?
p p2.warning
p p2.exception
