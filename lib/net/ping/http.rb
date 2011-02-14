require File.join(File.dirname(__FILE__), 'ping')
require 'net/http'
require 'net/https'
require 'uri'

# Force non-blocking Socket.getaddrinfo on Unix systems. Do not use on
# Windows because it (ironically) causes blocking problems.
unless File::ALT_SEPARATOR
  require 'resolv-replace'
end

# The Net module serves as a namespace only.
module Net

  # The Ping::HTTP class encapsulates methods for HTTP pings.
  class Ping::HTTP < Ping

    # By default an http ping will follow a redirect and give you the result
    # of the final URI.  If this value is set to false, then it will not
    # follow a redirect and will return false immediately on a redirect.
    #
    attr_accessor :follow_redirect

    # The maximum number of redirects allowed. The default is 5.
    attr_accessor :redirect_limit

    # The user agent used for the HTTP request. The default is nil.
    attr_accessor :user_agent

    # Creates and returns a new Ping::HTTP object.  Note that the default
    # port for Ping::HTTP is 80.
    #
    def initialize(uri=nil, port=80, timeout=5)
      @follow_redirect = true
      @redirect_limit  = 5
      super(uri, port, timeout)
    end

    # Looks for an HTTP response from the URI passed to the constructor.
    # If the result is a kind of Net::HTTPSuccess then the ping was
    # successful and true is returned.  Otherwise, false is returned
    # and the Ping::HTTP#exception method should contain a string
    # indicating what went wrong.
    #
    # If the HTTP#follow_redirect accessor is set to true (which it is
    # by default) and a redirect occurs during the ping, then the
    # HTTP#warning attribute is set to the redirect message, but the
    # return result is still true. If it's set to false then a redirect
    # response is considered a failed ping.
    #
    # If no file or path is specified in the URI, then '/' is assumed.
    #
    def ping(host = @host)
      super(host)
      bool = false
      uri = URI.parse(host)

      start_time = Time.now

      begin
        response = nil
        uri_path = uri.path.empty? ? '/' : uri.path
        headers = { }
        headers["User-Agent"] = user_agent unless user_agent.nil?
        Timeout.timeout(@timeout) do
          Net::HTTP.new(uri.host, @port).start do |http|
            response = http.request_get(uri_path, headers)
          end
        end
      rescue Exception => err
        @exception = err.message
      else
        if response.is_a?(Net::HTTPSuccess)
          bool = true
        else
          if @follow_redirect
            @warning = response.message
            rlimit = 0

            # Any response code in the 300 range is a redirect
            while response.code.to_i >= 300 && response.code.to_i < 400
              if rlimit >= redirect_limit
                @exception = "Redirect limit exceeded"
                break
              end
              redirect = URI.parse(response['location'])
              redirect = uri + redirect if redirect.relative?
              response = Net::HTTP.get_response(redirect.host, redirect.path, @port)
              rlimit += 1
            end

            if response.is_a?(Net::HTTPSuccess)
              bool = true
            else
              @warning = nil
              @exception ||= response.message
            end
          else
            @exception = response.message
          end
        end
      end

      # There is no duration if the ping failed
      @duration = Time.now - start_time if bool

      bool
    end

    alias ping? ping
    alias pingecho ping
    alias follow_redirect? follow_redirect
    alias uri host
    alias uri= host=
  end
end
