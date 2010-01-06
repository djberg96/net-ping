################################################################
# test_net_ping_udp.rb
#
# Test case for the Net::Ping::UDP class. This should be run
# via the 'test' or 'test:udp' Rake task.
#
# If someone could provide me a host where a udp ping actually
# works (with a service check), I would appreciate it. :)
################################################################
require 'rubygems'
gem 'test-unit'

require 'test/unit'
require 'net/ping/udp'
include Net

class TC_PingUDP < Test::Unit::TestCase
   def setup
      Ping::UDP.service_check = false
      @host = '127.0.0.1'
      @udp  = Ping::UDP.new(@host)
   end

   def test_version
      assert_equal('1.3.2', Ping::UDP::VERSION)
   end
   
   def test_ping
      assert_respond_to(@udp, :ping)
      assert_nothing_raised{ @udp.ping }
      assert_nothing_raised{ @udp.ping(@host) }
   end

   def test_ping_aliases
      assert_respond_to(@udp, :ping?)
      assert_respond_to(@udp, :pingecho)
      assert_nothing_raised{ @udp.ping? }
      assert_nothing_raised{ @udp.ping?(@host) }
      assert_nothing_raised{ @udp.pingecho }
      assert_nothing_raised{ @udp.pingecho(@host) }
   end

   def test_ping_standard
      assert_equal(true, @udp.ping?)
      assert_equal(true, @udp.exception.nil?)
   end

   def test_bind
      assert_respond_to(@udp, :bind)
      assert_nothing_raised{ @udp.bind('127.0.0.1', 80) }
   end
   
   def test_duration
      assert_nothing_raised{ @udp.ping }
      assert_respond_to(@udp, :duration)
      assert_kind_of(Float, @udp.duration)
   end

   def test_host
      assert_respond_to(@udp, :host)
      assert_respond_to(@udp, :host=)
      assert_equal('127.0.0.1', @udp.host)
   end

   def test_port
      assert_respond_to(@udp, :port)
      assert_respond_to(@udp, :port=)
      assert_equal(7, @udp.port)
   end

   def test_timeout
      assert_respond_to(@udp, :timeout)
      assert_respond_to(@udp, :timeout=)
      assert_equal(5, @udp.timeout)
   end

   def test_exception
      assert_respond_to(@udp, :exception)
      assert_nothing_raised{ @udp.ping }
      assert_nil(@udp.exception)
   end

   def test_warning
      assert_respond_to(@udp, :warning)
   end
   
   def test_service_check
      assert_respond_to(Ping::UDP, :service_check)
      assert_respond_to(Ping::UDP, :service_check=)
      assert_equal(false, Ping::UDP.service_check) # Set in setup
   end
   
   def test_service_check_expected_failures
      assert_raise(ArgumentError){ Ping::UDP.service_check(1) }
      assert_raise(ArgumentError){ Ping::UDP.service_check = 1 }
   end

   def teardown
      @host = nil
      @udp  = nil
   end
end
