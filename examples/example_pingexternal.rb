########################################################################
# example_pingexternal.rb
#
# A short sample program demonstrating an external ping. You can run
# this program via the example:external task. Modify as you see fit.
########################################################################
require 'net/ping'

good = 'www.rubyforge.org'
bad  = 'foo.bar.baz'

p1 = Net::Ping::External.new(good)
p p1.ping?

p2 = Net::Ping::External.new(bad)
p p2.ping?
