########################################################################
# example_pingldap.rb
#
# A short sample program demonstrating an ldap ping. You can run
# this program via the example:ldap task. Modify as you see fit.
########################################################################
require 'net/ping/ldap'

good = 'ldap://localhost'
bad  = 'ldap://example.com'

puts "== Good ping (if you have an ldap server at #{good})"

p1 = Net::Ping::LDAP.new(good)
p p1.ping?

puts "== Bad ping"

p2 = Net::Ping::LDAP.new(bad)
p p2.ping?
p p2.warning
p p2.exception
