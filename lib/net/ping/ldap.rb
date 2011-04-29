require File.join(File.dirname(__FILE__), 'ping')
require 'net/ldap'
require 'uri'


# The Net module serves as a namespace only.
module Net

  # The Ping::LDAP class encapsulates methods for LDAP pings.
  class Ping::LDAP < Ping

    attr_accessor :uri
    attr_accessor :username
    attr_accessor :password
    attr_accessor :encryption
    def encryption=(value)
      @encryption = (value.is_a? Symbol) ? value : value.to_sym
    end

    # Creates and returns a new Ping::LDAP object. The default port is the
    # port associated with the URI. The default timeout is 5 seconds.
    #
    def initialize(host=nil, timeout=5)
      host, port = decode_uri(host)
      super(host, port, timeout)
    end

    def decode_uri(value)
      @uri = URI.parse(value)
      if uri.scheme =~ /ldap/
        p = @port = uri.port
        h = @host = uri.host
        @encryption = uri.scheme=='ldaps' ? :simple_tls : nil
      else
        h = value
        p = 389
      end
      [h, p]
    end

    def config
      conf = {
        :host => uri.host,
        :port => uri.port,
        :encryption => encryption
      }
      conf.merge!(
        (username && password) ?
        { :auth => {:method => :simple, :username => username, :password => password} } :
        { :auth => {:method => :anonymous} }
      )
      conf
    end

    #
    def ping(host = nil)
      decode_uri(host) if host
      super(@host)
      
      bool = false

      start_time = Time.now

      begin
        Timeout.timeout(@timeout) do
          Net::LDAP.new( config  ).bind
        end
      rescue Net::LDAP::LdapError => e
        @exception = e.message
      rescue Exception => e
        @exception = e.message
      else
        bool = true
      end

      # There is no duration if the ping failed
      @duration = Time.now - start_time if bool

      bool
    end

    alias ping? ping
    alias pingecho ping
  end
end
