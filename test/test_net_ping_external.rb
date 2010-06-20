#########################################################################
# test_net_ping_external.rb
#
# Test case for the Net::PingExternal class. Run this via the 'test' or
# 'test:external' rake task.
#########################################################################
require 'rubygems'
gem 'test-unit'

require 'test/unit'
require 'net/ping/external'

class TC_Net_Ping_External < Test::Unit::TestCase
  def setup
    @host  = 'www.ruby-lang.org'
    @bogus = 'foo.bar.baz'
    @pe    = Net::Ping::External.new(@host)
    @bad   = Net::Ping::External.new(@bogus)
  end

  def test_ping
    assert_respond_to(@pe, :ping)
    assert_nothing_raised{ @pe.ping }
    assert_nothing_raised{ @pe.ping(@host) }
  end

  def test_ping_aliases
    assert_respond_to(@pe, :ping?)
    assert_respond_to(@pe, :pingecho)
    assert_nothing_raised{ @pe.ping? }
    assert_nothing_raised{ @pe.ping?(@host) }
    assert_nothing_raised{ @pe.pingecho }
    assert_nothing_raised{ @pe.pingecho(@host) }
  end

  def test_good_ping     
    assert_equal(true, @pe.ping?)
  end

  def test_bad_ping
    assert_equal(false, @bad.ping?)
    assert_equal(false, @bad.exception.nil?, "Bad exception data")
  end

  def test_duration
    assert_nothing_raised{ @pe.ping }
    assert_respond_to(@pe, :duration)
    assert_kind_of(Float, @pe.duration)
  end

  def test_host
    assert_respond_to(@pe, :host)
    assert_respond_to(@pe, :host=)
    assert_equal('www.ruby-lang.org', @pe.host)
  end

  def test_port
    assert_respond_to(@pe, :port)
    assert_respond_to(@pe, :port=)
    assert_equal(7, @pe.port)
  end

  def test_timeout
    assert_respond_to(@pe, :timeout)
    assert_respond_to(@pe, :timeout=)
    assert_equal(5, @pe.timeout)
  end

  def test_exception
    assert_respond_to(@pe, :exception)
    assert_nothing_raised{ @pe.ping }
    assert_nothing_raised{ @bad.ping }
    assert_nil(@pe.exception)
    assert_not_nil(@bad.exception)
  end

  def test_warning
    assert_respond_to(@pe, :warning)
  end

  def teardown
    @host  = nil
    @bogus = nil
    @pe    = nil
    @bad   = nil
  end
end
