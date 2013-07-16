#######################################################################
# test_net_ping_wmi.rb
#
# Test case for the Net::Ping::WMI class. These tests will only be
# run MS Windows.  You should run this test via the 'test' or
# 'test:wmi' Rake task.
#######################################################################
require 'test-unit'
require 'net/ping/wmi'
include Net

class TC_Ping_WMI < Test::Unit::TestCase
   def self.startup
      @@windows = File::ALT_SEPARATOR
   end

   def setup
      @host = "www.ruby-lang.org"
      @wmi = Ping::WMI.new(@host) if @@windows
   end

   def test_ping_basic
      omit_unless(@@windows, 'skipped on Unix platforms')
      assert_respond_to(@wmi, :ping)
      assert_nothing_raised{ @wmi.ping }
   end

   def test_ping_with_host
      omit_unless(@@windows, 'skipped on Unix platforms')
      assert_nothing_raised{ @wmi.ping(@host) }
   end

   def test_ping_with_options
      omit_unless(@@windows, 'skipped on Unix platforms')
      assert_nothing_raised{ @wmi.ping(@host, :NoFragmentation => true) }
   end

   def test_pingecho_alias
      omit_unless(@@windows, 'skipped on Unix platforms')
      assert_respond_to(@wmi, :pingecho)
      assert_nothing_raised{ @wmi.pingecho }
      assert_nothing_raised{ @wmi.pingecho(@host) }
   end

   def test_ping_returns_struct
      omit_unless(@@windows, 'skipped on Unix platforms')
      assert_kind_of(Struct::PingStatus, @wmi.ping)
   end

   def test_ping_returns_boolean
      omit_unless(@@windows, 'skipped on Unix platforms')
      assert_boolean(@wmi.ping?)
      assert_boolean(@wmi.ping?(@host))
   end

   def test_ping_expected_failure
      omit_unless(@@windows, 'skipped on Unix platforms')
      assert_false(Ping::WMI.new('bogus').ping?)
      assert_false(Ping::WMI.new('http://www.asdfhjklasdfhlkj.com').ping?)
   end

   def test_exception
      omit_unless(@@windows, 'skipped on Unix platforms')
      assert_respond_to(@wmi, :exception)
      assert_nothing_raised{ @wmi.ping }
      assert_nil(@wmi.exception)
   end

   def test_warning
      assert_respond_to(@wmi, :warning)
   end

   def teardown
      @host = nil
      @wmi  = nil
   end

   def self.shutdown
      @@windows = nil
   end
end
