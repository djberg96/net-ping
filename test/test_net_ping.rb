######################################################################
# test_net_ping.rb
#
# Test suite for all the Ping subclasses. Note that the Ping::ICMP
# class test won't be run unless this is run as a privileged process.
######################################################################
require 'test_net_ping_external'
require 'test_net_ping_http'
require 'test_net_ping_tcp'
require 'test_net_ping_udp'

if Process.euid == 0
  require 'test_net_ping_icmp'
end

if Config::CONFIG['host_os'] =~ /mswin|win32|dos|cygwin|mingw/i &&
  RUBY_PLATFORM != 'java'
then
  require 'test_net_ping_wmi'
end

class TC_Net_Ping < Test::Unit::TestCase
  def test_net_ping_version
    assert_equal('1.3.7', Net::Ping::VERSION)
  end
end
