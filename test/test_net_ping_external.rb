#########################################################################
# test_net_ping_external.rb
#
# Test case for the Net::PingExternal class. Run this via the 'test' or
# 'test:external' rake task.
#
# WARNING: I've noticed that test failures will occur if you're using
# OpenDNS. This is apparently caused by them messing with upstream
# replies for advertising purposes.
#########################################################################
require 'test-unit'
require 'net/ping/external'

class TC_Net_Ping_External < Test::Unit::TestCase
  def setup
    @host  = 'localhost'
    @bogus = 'foo.bar.baz'
    @pe    = Net::Ping::External.new(@host)
    @bad   = Net::Ping::External.new(@bogus)
  end

  test "ping basic functionality" do
    assert_respond_to(@pe, :ping)
  end

  test "ping with no arguments" do
    assert_nothing_raised{ @pe.ping }
  end

  test "ping accepts a hostname" do
    assert_nothing_raised{ @pe.ping(@host) }
  end

  test "ping returns a boolean" do
    assert_boolean(@pe.ping)
    assert_boolean(@bad.ping)
  end

  test "ping? alias" do
    assert_respond_to(@pe, :ping?)
    assert_alias_method(@pe, :ping?, :ping)
  end

  test "pingecho alias" do
    assert_nothing_raised{ @pe.pingecho }
    assert_alias_method(@pe, :pingecho, :ping)
  end

  test "pinging a good host returns true" do
    assert_true(@pe.ping?)
  end

  test "pinging a bogus host returns false" do
    assert_false(@bad.ping?)
  end

  test "duration basic functionality" do
    assert_nothing_raised{ @pe.ping }
    assert_respond_to(@pe, :duration)
    assert_kind_of(Float, @pe.duration)
  end

  test "duration is unset if a bad ping follows a good ping" do
    assert_nothing_raised{ @pe.ping }
    assert_not_nil(@pe.duration)
    assert_false(@pe.ping?(@bogus))
    assert_nil(@pe.duration)
  end

  test "host getter basic functionality" do
    assert_respond_to(@pe, :host)
    assert_equal('localhost', @pe.host)
  end

  test "host setter basic functionality" do
    assert_respond_to(@pe, :host=)
    assert_nothing_raised{ @pe.host = @bad }
    assert_equal(@bad, @pe.host)
  end

  test "port getter basic functionality" do
    assert_respond_to(@pe, :port)
    assert_equal(7, @pe.port)
  end

  test "port setter basic functionality" do
    assert_respond_to(@pe, :port=)
    assert_nothing_raised{ @pe.port = 90 }
    assert_equal(90, @pe.port)
  end

  test "timeout getter basic functionality" do
    assert_respond_to(@pe, :timeout)
    assert_equal(5, @pe.timeout)
  end

  test "timeout setter basic functionality" do
    assert_respond_to(@pe, :timeout=)
    assert_nothing_raised{ @pe.timeout = 30 }
    assert_equal(30, @pe.timeout)
  end

  test "exception method basic functionality" do
    assert_respond_to(@pe, :exception)
    assert_nil(@pe.exception)
  end

  test "pinging a bogus host stores exception data" do
    assert_nothing_raised{ @bad.ping? }
    assert_not_nil(@bad.exception)
  end

  test "pinging a good host results in no exception data" do
    assert_nothing_raised{ @pe.ping }
    assert_nil(@pe.exception)
  end

  test "warning basic functionality" do
    assert_respond_to(@pe, :warning)
    assert_nil(@pe.warning)
  end

  test "timing out causes expected result" do
    ext = Net::Ping::External.new('foo.bar.baz', nil, 1)
    start = Time.now
    assert_false(ext.ping?)
    elapsed = Time.now - start
    assert_true(elapsed < 2.5, "Actual elapsed: #{elapsed}")
    assert_not_nil(ext.exception)
  end

  test "pinging an unreachable host on the same subnet returns false" do
    @bad = Net::Ping::External.new('192.168.0.99')
    assert_false(@bad.ping?)
  end

  def teardown
    @host  = nil
    @bogus = nil
    @pe    = nil
    @bad   = nil
  end
end
