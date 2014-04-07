#################################################################################
# test_net_ping_http.rb
#
# Test case for the Net::PingHTTP class. This should be run via the 'test' or
# 'test:http' Rake task.
#################################################################################
require 'test-unit'
require 'fakeweb'
require 'net/ping/http'

class TC_Net_Ping_HTTP < Test::Unit::TestCase
  def setup
    ENV['http_proxy'] = ENV['https_proxy'] = ENV['no_proxy'] = nil
    @uri = 'http://www.google.com/index.html'
    @uri_https = 'https://encrypted.google.com'
    @proxy = 'http://username:password@proxymoxie:3128'
    FakeWeb.allow_net_connect = false

    FakeWeb.register_uri(:get, @uri, :body => "PONG")
    FakeWeb.register_uri(:head, @uri, :body => "PONG")
    FakeWeb.register_uri(:head, @uri_https, :body => "PONG")
    FakeWeb.register_uri(:get, @uri_https, :body => "PONG")
    FakeWeb.register_uri(:head, "http://jigsaw.w3.org/HTTP/300/302.html",
                         :body => "PONG",
                         :location => "#{@uri}",
                         :status => ["302", "Found"])

    FakeWeb.register_uri(:any, 'http://www.blabfoobarurghxxxx.com', :exception => SocketError)
    FakeWeb.register_uri(:head, 'http://http502.com',
                         :body => "",
                         :status => ["502", "Bad Gateway"])

    @http = Net::Ping::HTTP.new(@uri, 80, 30)
    @bad  = Net::Ping::HTTP.new('http://www.blabfoobarurghxxxx.com') # One hopes not
  end

  test 'ping basic functionality' do
    assert_respond_to(@http, :ping)
    assert_nothing_raised{ @http.ping }
  end

  test 'ping returns a boolean value' do
    assert_boolean(@http.ping?)
    assert_boolean(@bad.ping?)
  end

  test 'ping? is an alias for ping' do
    assert_alias_method(@http, :ping?, :ping)
  end

  test 'pingecho is an alias for ping' do
    assert_alias_method(@http, :pingecho, :ping)
  end

  test 'ping should succeed for a valid website' do
    assert_true(@http.ping?)
  end

  test 'ping should fail for an invalid website' do
    assert_false(@bad.ping?)
  end

  test 'duration basic functionality' do
    assert_respond_to(@http, :duration)
    assert_nothing_raised{ @http.ping }
  end

  test 'duration returns a float value on a successful ping' do
    assert_true(@http.ping)
    assert_kind_of(Float, @http.duration)
  end

  test 'duration is nil on an unsuccessful ping' do
    assert_false(@bad.ping)
    assert_nil(@http.duration)
  end

  test 'host attribute basic functionality' do
    assert_respond_to(@http, :host)
    assert_respond_to(@http, :host=)
    assert_equal('http://www.google.com/index.html', @http.host)
  end

  test 'uri is an alias for host' do
    assert_alias_method(@http, :uri, :host)
    assert_alias_method(@http, :uri=, :host=)
  end

  test 'port attribute basic functionality' do
    assert_respond_to(@http, :port)
    assert_respond_to(@http, :port=)
  end

  test 'port attribute is set to expected value' do
    assert_equal(80, @http.port)
    assert_equal(443, Net::Ping::HTTP.new('https://github.com/path').port)
    assert_equal(80, Net::Ping::HTTP.new.port)
  end

  test 'timeout attribute basic functionality' do
    assert_respond_to(@http, :timeout)
    assert_respond_to(@http, :timeout=)
  end

  test 'timeout attribute expected values' do
    assert_equal(30, @http.timeout)
    assert_equal(5, @bad.timeout)
  end

  # TODO: Figure out how to do this with FakeWeb.
  test 'ping fails if timeout exceeded' do
    FakeWeb.allow_net_connect = true
    @http = Net::Ping::HTTP.new('https://github.com/path', 80, 0.01)
    assert_false(@http.ping?)
    assert_equal('execution expired', @http.exception)
  end

  test 'exception attribute basic functionality' do
    assert_respond_to(@http, :exception)
    assert_nil(@http.exception)
  end

  test 'exception attribute is nil if the ping is successful' do
    assert_true(@http.ping)
    assert_nil(@http.exception)
  end

  test 'exception attribute is not nil if the ping is unsuccessful' do
    assert_false(@bad.ping)
    assert_not_nil(@bad.exception)
  end

  test 'warning attribute basic functionality' do
    assert_respond_to(@http, :warning)
    assert_nil(@http.warning)
  end

  test 'code attribute is set' do
    assert_true(@http.ping)
    assert_equal('200', @http.code)
  end

  test 'user_agent accessor is defined' do
    assert_respond_to(@http, :user_agent)
    assert_respond_to(@http, :user_agent=)
  end

  test 'user_agent defaults to nil' do
    assert_nil(@http.user_agent)
  end

  test 'ping with user agent' do
    @http.user_agent = "KDDI-CA32"
    assert_true(@http.ping)
  end

  test 'redirect_limit accessor is defined' do
    assert_respond_to(@http, :redirect_limit)
    assert_respond_to(@http, :redirect_limit=)
  end

  test 'redirect_limit defaults to 5' do
    assert_equal(5, @http.redirect_limit)
  end

  test 'redirects succeed by default' do
    @http = Net::Ping::HTTP.new("http://jigsaw.w3.org/HTTP/300/302.html")
    assert_true(@http.ping)
  end

  test 'redirect fail if follow_redirect is set to false' do
    @http = Net::Ping::HTTP.new("http://jigsaw.w3.org/HTTP/300/302.html")
    @http.follow_redirect = false
    assert_false(@http.ping)
  end

  test 'ping with redirect limit set to zero fails' do
    @http = Net::Ping::HTTP.new("http://jigsaw.w3.org/HTTP/300/302.html")
    @http.redirect_limit  = 0
    assert_false(@http.ping)
    assert_equal("Redirect limit exceeded", @http.exception)
  end

  test 'http 502 sets exception' do
    @http = Net::Ping::HTTP.new("http://http502.com")
    assert_false(@http.ping)
    assert_equal('Bad Gateway', @http.exception)
  end

  test 'http 502 sets code' do
    @http = Net::Ping::HTTP.new("http://http502.com")
    assert_false(@http.ping)
    assert_equal('502', @http.code)
  end

  test 'ping against https site defaults to port 443' do
    @http = Net::Ping::HTTP.new(@uri_https)
    assert_equal(443, @http.port)
  end

  test 'ping against https site works as expected' do
    @http = Net::Ping::HTTP.new(@uri_https)
    assert_true(@http.ping)
  end

  test 'ping with get option' do
    @http = Net::Ping::HTTP.new(@uri)
    @http.get_request = true
    assert_true(@http.ping)
  end

  test 'ping with http proxy' do
    ENV['http_proxy'] = "http://proxymoxie:3128"
    @http = Net::Ping::HTTP.new(@uri)
    @http.get_request = true
    assert_true(@http.ping)
    assert_true(@http.proxied)
  end

  test 'ping with https proxy' do
    ENV['https_proxy'] = "http://proxymoxie:3128"
    @http = Net::Ping::HTTP.new(@uri_https)
    @http.get_request = true
    assert_true(@http.ping)
    assert_true(@http.proxied)
  end

  test 'ping with no_proxy' do
    ENV['no_proxy'] = "google.com"
    @http = Net::Ping::HTTP.new(@uri)
    @http.get_request = true
    assert_true(@http.ping)
    assert_false(@http.proxied)
  end

  def teardown
    @uri  = nil
    @http = nil
  end
end
