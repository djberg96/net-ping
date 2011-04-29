#################################################################################
# test_net_ping_http.rb
#
# Test case for the Net::PingHTTP class. This should be run via the 'test' or
# 'test:http' Rake task.
#################################################################################
require 'rubygems'
gem 'test-unit'

require 'test/unit'
require 'net/ping/ldap'
require 'fakeldap'

class TC_Net_Ping_LDAP < Test::Unit::TestCase
  class << self
    def startup
      @@host = 'localhost'
      @@port = 2389
      @@uri = "ldap://#{@@host}:#{@@port}"
      @@timeout = 30
      @@cn = 'el.Daper'
      @@password = 'ldappassword'
      
      @@ldap_server = FakeLDAP::Server.new(:port => @@port)
      @@ldap_server.run_tcpserver
      @@ldap_server.add_user("cn=#{@@cn},ou=USERS,dc=example,dc=com", @@password)
    end
    def shutdown
      @@ldap_server.stop
    end
  end
  def setup
    @ldap = Net::Ping::LDAP.new(@@uri, @@timeout)
    @ldap.username = @@cn
    @ldap.password = @@password
    @bad  = Net::Ping::LDAP.new('ldap://blabfoobarurghxxxx.com') # One hopes not
  end

  def teardown
    @ldap = nil
  end

  test 'ping basic functionality' do
    assert_respond_to(@ldap, :ping)
    assert_nothing_raised{ @ldap.ping }
  end

  test 'ping returns a boolean value' do
    assert_boolean(@ldap.ping?)
    assert_boolean(@bad.ping?)
  end

  test 'ping? is an alias for ping' do
    assert_alias_method(@ldap, :ping?, :ping)
  end

  test 'pingecho is an alias for ping' do
    assert_alias_method(@ldap, :pingecho, :ping)
  end

  test 'ping should succeed for a valid website' do
    assert_true(@ldap.ping?)
  end

  test 'ping should fail for an invalid website' do
    assert_false(@bad.ping?)
  end

  test 'duration basic functionality' do
    assert_respond_to(@ldap, :duration)
    assert_nothing_raised{ @ldap.ping }
  end

  test 'duration returns a float value on a successful ping' do
    assert_true(@ldap.ping)
    assert_kind_of(Float, @ldap.duration)
  end

  test 'duration is nil on an unsuccessful ping' do
    assert_false(@bad.ping)
    assert_nil(@ldap.duration)
  end

  test 'host attribute basic functionality' do
    assert_respond_to(@ldap, :host)
    assert_respond_to(@ldap, :host=)
    assert_equal(@@host, @ldap.host)
  end
  
  test 'port attribute basic functionality' do
    assert_respond_to(@ldap, :port)
    assert_respond_to(@ldap, :port=)
  end

  test 'port attribute expected value' do
    assert_equal(@@port, @ldap.port)
  end

  test 'timeout attribute basic functionality' do
    assert_respond_to(@ldap, :timeout)
    assert_respond_to(@ldap, :timeout=)
  end

  test 'timeout attribute expected values' do
    assert_equal(@@timeout, @ldap.timeout)
    assert_equal(5, @bad.timeout)
  end

  test 'exception attribute basic functionality' do
    assert_respond_to(@ldap, :exception)
    assert_nil(@ldap.exception)
  end

  test 'exception attribute is nil if the ping is successful' do
    assert_true(@ldap.ping)
    assert_nil(@ldap.exception)
  end

  test 'exception attribute is not nil if the ping is unsuccessful' do
    assert_false(@bad.ping)
    assert_not_nil(@bad.exception)
  end

  test 'warning attribute basic functionality' do
    assert_respond_to(@ldap, :warning)
    assert_nil(@ldap.warning)
  end

  test 'uri attribute basic functionality' do
    assert_respond_to(@ldap, :uri)
    assert_respond_to(@ldap, :uri=)
  end

  test 'username attribute basic functionality' do
    assert_respond_to(@ldap, :username)
    assert_respond_to(@ldap, :username=)
  end

  test 'password attribute basic functionality' do
    assert_respond_to(@ldap, :password)
    assert_respond_to(@ldap, :password=)
  end

  test 'encryption attribute basic functionality' do
    assert_respond_to(@ldap, :encryption)
    assert_respond_to(@ldap, :encryption=)
  end

  test 'encryption defaults to nil for ldap' do
    assert_nil(Net::Ping::LDAP.new('ldap://somehost.example.net').encryption)
  end

  test 'encryption defaults to simple_tls for ldaps' do
    assert_equal(:simple_tls, Net::Ping::LDAP.new('ldaps://somehost.example.net').encryption)
  end

  test 'port defaults to 389 for ldap' do
    assert_equal(389, Net::Ping::LDAP.new('ldap://somehost.example.net').port)
  end

  test 'port defaults to 636 for ldaps' do
    assert_equal(636, Net::Ping::LDAP.new('ldaps://somehost.example.net').port)
  end

  test 'port extracted from uri if provided' do
    assert_equal(12345, Net::Ping::LDAP.new('ldap://somehost.example.net:12345').port)
    assert_equal(12345, Net::Ping::LDAP.new('ldaps://somehost.example.net:12345').port)
  end

  test 'encryption setting is forced to symbol' do
    @ldap.encryption = 'simple_tls'
    assert_true( @ldap.encryption.is_a? Symbol )
    assert_true( @ldap.config[:encryption].is_a? Symbol )
  end

  test 'username/password set in config auth section' do
    @ldap.username, @ldap.password = 'fred', 'derf'
    assert_equal('fred', @ldap.config[:auth][:username] )
    assert_equal('derf', @ldap.config[:auth][:password] )
  end

  test 'auth method defaults to simple if username/password set' do
    @ldap.username, @ldap.password = 'fred', 'derf'
    assert_equal(:simple, @ldap.config[:auth][:method] )
  end

  test 'if no username/password then defaults to auth anonymous' do
    @ldap.username = @ldap.password = nil
    assert_equal({:method => :anonymous}, @ldap.config[:auth] )
  end

end