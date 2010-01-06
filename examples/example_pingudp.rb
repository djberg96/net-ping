########################################################################
# example_pingudp.rb
#
# A short sample program demonstrating a UDP ping. You can run
# this program via the example:udp task. Modify as you see fit.
########################################################################
require 'net/ping'

host = 'www.google.com'

u = Net::Ping::UDP.new(host)
p u.ping?
