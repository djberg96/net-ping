########################################################################
# example_pingtcp.rb
#
# A short sample program demonstrating a tcp ping. You can run
# this program via the example:tcp task. Modify as you see fit.
########################################################################
require 'net/ping'

good = 'www.google.com'
bad  = 'foo.bar.baz'

p1 = Net::Ping::TCP.new(good, 'http')
p p1.ping?

p2 = Net::Ping::TCP.new(bad)
p p2.ping?
