#######################################################################
# test_net_ping_icmp.rb
#
# Test case for the Net::PingICMP class.  You must run this test case
# with root privileges on UNIX systems. This should be run via the
# 'test' or 'test:icmp' Rake task.
#######################################################################
require 'rubygems'
gem 'test-unit'

require 'test/unit'
require 'net/ping/icmp'
include Net

unless Process.euid == 0
   raise "The test:icmp task must be run with root privileges"
end

class TC_PingICMP < Test::Unit::TestCase
   def self.startup
      @@one_click = Config::CONFIG['host_os'] == 'mswin32'
   end
   
   def setup
      @host = 'localhost'
      @icmp = Ping::ICMP.new(@host)
   end

   def test_ping
      assert_respond_to(@icmp, :ping)
      
      omit_if(@@one_click, 'Unreliable socket library')

      assert_nothing_raised{ @icmp.ping }
      assert_nothing_raised{ @icmp.ping(@host) }
   end

   def test_ping_aliases_basic
      assert_respond_to(@icmp, :ping?)
      assert_respond_to(@icmp, :pingecho)

      omit_if(@@one_click, 'Unreliable socket library')

      assert_nothing_raised{ @icmp.ping? }
      assert_nothing_raised{ @icmp.ping?(@host) }
   end

   def test_ping_returns_boolean
      omit_if(@@one_click, 'Unreliable socket library')
      assert_boolean(@icmp.pingecho)
      assert_boolean(@icmp.pingecho(@host))
   end
   
   def test_ping_expected_failure
      omit_if(@@one_click, 'Unreliable socket library')
      assert_false(Ping::ICMP.new('bogus').ping?)
      assert_false(Ping::ICMP.new('http://www.asdfhjklasdfhlkj.com').ping?)      
   end

   def test_bind
      omit_if(@@one_click, 'Unreliable socket library')
      assert_respond_to(@icmp, :bind)
      assert_nothing_raised{ @icmp.bind(Socket.gethostname) }
      assert_nothing_raised{ @icmp.bind(Socket.gethostname, 80) }
   end

   def test_duration
      omit_if(@@one_click, 'Unreliable socket library')
      assert_nothing_raised{ @icmp.ping }
      assert_respond_to(@icmp, :duration)
      assert_kind_of(Float, @icmp.duration)
   end

   def test_host
      assert_respond_to(@icmp, :host)
      assert_respond_to(@icmp, :host=)
      assert_equal('localhost', @icmp.host)
   end

   def test_port
      assert_respond_to(@icmp, :port)
      assert_equal(nil, @icmp.port)
   end

   def test_timeout
      assert_respond_to(@icmp, :timeout)
      assert_respond_to(@icmp, :timeout=)
      assert_equal(5, @icmp.timeout)
   end

   def test_exception
      assert_respond_to(@icmp, :exception)
      omit_if(@@one_click, 'Unreliable socket library')
      assert_nothing_raised{ @icmp.ping }
      assert_nil(@icmp.exception)
   end

   def test_warning
      assert_respond_to(@icmp, :warning)
   end

   def test_data_size_get
      assert_respond_to(@icmp, :data_size)
      assert_equal(56, @icmp.data_size)
   end

   def test_data_size_set
      assert_respond_to(@icmp, :data_size=)
      assert_nothing_raised{ @icmp.data_size = 22 }
   end

   def test_odd_data_size_ok
      assert_nothing_raised{ @icmp.data_size = 57 }
      omit_if(@@one_click, 'Unreliable socket library')
      assert_boolean(@icmp.ping)
   end

   def teardown
      @host = nil
      @icmp = nil
   end
   
   def self.shutdown
      @@one_click = nil      
   end
end
