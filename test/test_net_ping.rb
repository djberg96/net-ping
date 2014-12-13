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
require 'fakeweb'

if File::ALT_SEPARATOR
  require 'win32/security'

  if Win32::Security.elevated_security?
    require 'test_net_ping_icmp'
  end
else
  if Process.euid == 0
    require 'test_net_ping_icmp'
  end
end

if File::ALT_SEPARATOR
  require 'test_net_ping_wmi'
end

class TC_Net_Ping < Test::Unit::TestCase
  def test_net_ping_version
    assert_equal('1.7.6', Net::Ping::VERSION)
  end
end

FakeWeb.allow_net_connect = false
