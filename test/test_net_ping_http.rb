#################################################################################
# test_net_ping_http.rb
#
# Test case for the Net::PingHTTP class. This should be run via the 'test' or
# 'test:http' Rake task.
#################################################################################
require 'rubygems'
gem 'test-unit'

require 'test/unit'
require 'net/ping/http'
include Net

class TC_PingHTTP < Test::Unit::TestCase
   def setup
      @uri  = 'http://www.google.com/index.html'
      @http = Ping::HTTP.new(@uri, 80, 30)      
      @bad  = Ping::HTTP.new('http://www.blabfoobarurgh.com') # One hopes not
   end

   def test_version
      assert_equal('1.3.2', Ping::HTTP::VERSION)
   end
   
   def test_ping
      assert_respond_to(@http, :ping)
      assert_nothing_raised{ @http.ping }
   end

   def test_ping_aliases
      assert_respond_to(@http, :ping?)
      assert_respond_to(@http, :pingecho)
      assert_nothing_raised{ @http.ping? }
      assert_nothing_raised{ @http.pingecho }
   end

   def test_ping_success
      assert_equal(true, @http.ping?)
      assert_equal(false, @bad.ping?)
      assert_not_nil(@bad.exception)
   end

   def test_duration
      assert_nothing_raised{ @http.ping }
      assert_respond_to(@http, :duration)
      assert_kind_of(Float, @http.duration)
   end

   def test_host
      assert_respond_to(@http, :host)
      assert_respond_to(@http, :host=)
      assert_respond_to(@http, :uri)   # Alias
      assert_respond_to(@http, :uri=)  # Alias
      assert_equal('http://www.google.com/index.html', @http.host)
   end

   def test_port
      assert_respond_to(@http, :port)
      assert_respond_to(@http, :port=)
      assert_equal(80, @http.port)
   end

   def test_timeout
      assert_respond_to(@http, :timeout)
      assert_respond_to(@http, :timeout=)
      assert_equal(30, @http.timeout)
      assert_equal(5, @bad.timeout)
   end

   def test_exception
      assert_respond_to(@http, :exception)
      assert_nothing_raised{ @http.ping }
      assert_nothing_raised{ @bad.ping }
      assert_nil(@http.exception)
      assert_not_nil(@bad.exception)
   end

   def test_warning
      assert_respond_to(@http, :warning)
   end

   def teardown
      @uri  = nil
      @http = nil
   end
end
