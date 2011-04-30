require File.join(File.dirname(__FILE__), 'ping')
require 'net/ldap'
require 'uri'


# The Net module serves as a namespace only.
module Net

  # The Ping::LDAP class encapsulates methods for LDAP pings.
  class Ping::LDAP < Ping

    # uri contains the URI object for the request
    #
    attr_accessor :uri

    # username and password may be set for ping using
    # an authenticated LDAP bind
    #
    attr_accessor :username
    attr_accessor :password

    # set/get the encryption method. By default nil,
    # but may be set to :simple_tls
    #
    attr_accessor :encryption
    def encryption=(value)
      @encryption = (value.is_a? Symbol) ? value : value.to_sym
    end

    # Creates and returns a new Ping::LDAP object.
    # The default +timeout+ is 5 seconds.
    #
    # +uri+ string is expected to be a full URI with scheme (ldap/ldaps)
    # and optionally the port (else default port is assumed) e.g.
    #   ldap://my.ldap.host.com
    #   ldap://my.ldap.host.com:1389
    #   ldaps://my.ldap.host.com
    #   ldaps://my.ldap.host.com:6636
    #
    # If a plain hostname is provided as the +uri+, a default port of 389 is assumed
    #
    def initialize(uri=nil, timeout=5)
      host, port = decode_uri(uri)
      super(host, port, timeout)
    end

    # method used to decode uri string
    #
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

    # constructs the LDAP configuration structure
    #
    def config
      {
        :host => uri.host,
        :port => uri.port,
        :encryption => encryption
      }.merge(
        (username && password) ?
        { :auth => {:method => :simple, :username => username, :password => password} } :
        { :auth => {:method => :anonymous} }
      )
    end

    # perform ping, optionally providing the ping destination uri
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
