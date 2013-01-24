#####################################################################
# test_net_ping_tcp.rb
#
# Test case for the Net::PingTCP class. This test should be run via
# the 'test' or 'test:tcp' Rake task.
#####################################################################
require 'test-unit'
require 'net/ping/tcp'
include Net

class TC_PingTCP < Test::Unit::TestCase
  def setup
    @host = 'localhost'
    @port = 22
    @tcp  = Ping::TCP.new(@host, @port)
  end

  def test_ping
    assert_respond_to(@tcp, :ping)
    assert_nothing_raised{ @tcp.ping }
    assert_nothing_raised{ @tcp.ping(@host) }
  end

  def test_ping_aliases
    assert_respond_to(@tcp, :ping?)
    assert_respond_to(@tcp, :pingecho)
    assert_nothing_raised{ @tcp.ping? }
    assert_nothing_raised{ @tcp.ping?(@host) }
    assert_nothing_raised{ @tcp.pingecho }
    assert_nothing_raised{ @tcp.pingecho(@host) }
  end

  def test_ping_service_check_false
    msg = "+this test may fail depending on your network environment+"
    Ping::TCP.service_check = false
    @tcp = Ping::TCP.new('localhost')
    assert_false(@tcp.ping?, msg)
    assert_false(@tcp.exception.nil?, "Bad exception data")
  end

  def test_ping_service_check_true
    msg = "+this test may fail depending on your network environment+"
    Ping::TCP.service_check = true
    assert_true(@tcp.ping?, msg)
  end
   
  def test_service_check
    assert_respond_to(Ping::TCP, :service_check)
    assert_respond_to(Ping::TCP, :service_check=)    
  end
   
  # These will be removed eventually
  def test_service_check_aliases
    assert_respond_to(Ping::TCP, :econnrefused)
    assert_respond_to(Ping::TCP, :econnrefused=)
    assert_respond_to(Ping::TCP, :ecr)
    assert_respond_to(Ping::TCP, :ecr=)     
  end
   
  def test_service_check_expected_errors
    assert_raises(ArgumentError){ Ping::TCP.service_check = "blah" }
  end
   
  # If the ping failed, the duration will be nil
  def test_duration
    assert_nothing_raised{ @tcp.ping }
    assert_respond_to(@tcp, :duration)
    omit_if(@tcp.duration.nil?, 'ping failed, skipping')
    assert_kind_of(Float, @tcp.duration)
  end

  def test_host
    assert_respond_to(@tcp, :host)
    assert_respond_to(@tcp, :host=)
    assert_equal(@host, @tcp.host)
  end

  def test_port
    assert_respond_to(@tcp, :port)
    assert_respond_to(@tcp, :port=)
    assert_equal(22, @tcp.port)
  end

  def test_timeout
    assert_respond_to(@tcp, :timeout)
    assert_respond_to(@tcp, :timeout=)
    assert_equal(5, @tcp.timeout)
  end

  def test_exception
    msg = "+this test may fail depending on your network environment+"
    assert_respond_to(@tcp, :exception)
    assert_nothing_raised{ @tcp.ping }
    assert_nil(@tcp.exception, msg)
  end

  def test_warning
    assert_respond_to(@tcp, :warning)
  end

  def teardown
    @host = nil
    @tcp  = nil
  end
end
