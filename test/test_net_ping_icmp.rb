#######################################################################
# test_net_ping_icmp.rb
#
# Test case for the Net::PingICMP class. You must run this test case
# with root privileges on UNIX systems. This should be run via the
# 'test' or 'test:icmp' Rake task.
#######################################################################
require 'test-unit'
require 'net/ping/icmp'
require 'thread'

if File::ALT_SEPARATOR
  require 'win32/security'

  unless Win32::Security.elevated_security?
    raise "The test:icmp task must be run with elevated security rights"
  end
else
  unless Process.euid == 0
    raise "The test:icmp task must be run with root privileges"
  end
end

class TC_PingICMP < Test::Unit::TestCase
  def self.startup
    @@jruby = RUBY_PLATFORM == 'java'
  end

  def setup
    @host = '127.0.0.1' # 'localhost'
    @icmp = Net::Ping::ICMP.new(@host)
    @concurrency = 3
  end

  test "icmp ping basic functionality" do
    assert_respond_to(@icmp, :ping)
    omit_if(@@jruby)
    assert_nothing_raised{ @icmp.ping }
  end

  test "icmp ping accepts a host" do
    omit_if(@@jruby)
    assert_nothing_raised{ @icmp.ping(@host) }
  end

  test "icmp ping returns a boolean" do
    omit_if(@@jruby)
    assert_boolean(@icmp.ping)
    assert_boolean(@icmp.ping(@host))
  end

  test "icmp ping of local host is successful" do
    omit_if(@@jruby)
    assert_true(Net::Ping::ICMP.new(@host).ping?)
    assert_true(Net::Ping::ICMP.new('192.168.0.1').ping?)
  end

  test "threaded icmp ping returns expected results" do
    omit_if(@@jruby)
    ips = ['8.8.4.4', '8.8.9.9', '127.0.0.1', '8.8.8.8', '8.8.8.9']
    queue = Queue.new
    threads = []

    ips.each{ |ip| queue <<  ip }

    @concurrency.times{
      threads << Thread.new(queue) do |q|
        ip = q.pop
        icmp = Net::Ping::ICMP.new(ip, nil, 1)
        if ip =~ /9/
          assert_false(icmp.ping?)
        else
          assert_true(icmp.ping?)
        end
      end
    }

    threads.each{ |t| t.join }
  end

  test "ping? is an alias for ping" do
    assert_respond_to(@icmp, :ping?)
    assert_alias_method(@icmp, :ping?, :ping)
  end

  test "pingecho is an alias for ping" do
    assert_respond_to(@icmp, :pingecho)
    assert_alias_method(@icmp, :pingecho, :ping)
  end

  test "icmp ping fails if host is invalid" do
    omit_if(@@jruby)
    assert_false(Net::Ping::ICMP.new('bogus').ping?)
    assert_false(Net::Ping::ICMP.new('http://www.asdfhjklasdfhlkj.com').ping?)
  end

  test "bind method basic functionality" do
    assert_respond_to(@icmp, :bind)
    assert_nothing_raised{ @icmp.bind(Socket.gethostname) }
    assert_nothing_raised{ @icmp.bind(Socket.gethostname, 80) }
  end

  test "duration method basic functionality" do
    omit_if(@@jruby)
    assert_nothing_raised{ @icmp.ping }
    assert_respond_to(@icmp, :duration)
    assert_kind_of(Float, @icmp.duration)
  end

  test "host getter method basic functionality" do
    assert_respond_to(@icmp, :host)
    assert_equal(@host, @icmp.host)
  end

  test "host setter method basic functionality" do
    assert_respond_to(@icmp, :host=)
    assert_nothing_raised{ @icmp.host = '192.168.0.1' }
    assert_equal(@icmp.host, '192.168.0.1')
  end

  test "port method basic functionality" do
    assert_respond_to(@icmp, :port)
    assert_equal(nil, @icmp.port)
  end

  test "timeout getter method basic functionality" do
    assert_respond_to(@icmp, :timeout)
    assert_equal(5, @icmp.timeout)
  end

  test "timeout setter method basic functionality" do
    assert_respond_to(@icmp, :timeout=)
    assert_nothing_raised{ @icmp.timeout = 7 }
    assert_equal(7, @icmp.timeout)
  end

  test "timeout works as expected" do
    omit_if(@@jruby)
    icmp = Net::Ping::ICMP.new('bogus.com', nil, 0.000001)
    assert_false(icmp.ping?)
    assert_kind_of(Timeout::Error, icmp.exception)
  end

  test "exception method basic functionality" do
    assert_respond_to(@icmp, :exception)
  end

  test "exception method returns nil if no ping has happened yet" do
    assert_nil(@icmp.exception)
  end

  test "warning method basic functionality" do
    assert_respond_to(@icmp, :warning)
  end

  test "data_size getter method basic functionality" do
    assert_respond_to(@icmp, :data_size)
    assert_nothing_raised{ @icmp.data_size }
    assert_kind_of(Numeric, @icmp.data_size)
  end

  test "data_size returns expected value" do
    assert_equal(56, @icmp.data_size)
  end

  test "data_size setter method basic functionality" do
    assert_respond_to(@icmp, :data_size=)
    assert_nothing_raised{ @icmp.data_size = 22 }
  end

  test "setting an odd data_size is valid" do
    omit_if(@@jruby)
    assert_nothing_raised{ @icmp.data_size = 57 }
    assert_boolean(@icmp.ping)
  end

  def teardown
    @host = nil
    @icmp = nil
    @concurrency = nil
  end

  def self.shutdown
    @@jruby = nil
  end
end
