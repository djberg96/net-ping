require 'java'
require_relative 'ping'
require 'win32/security' if File::ALT_SEPARATOR
import java.lang.System

# The Net module serves as a namespace only.
module Net

  # The Net::Ping::ICMP class encapsulates an icmp ping.
  class Ping::ICMP < Ping
    # You cannot set or change the port value. A value of 0 is always
    # used internally for ICMP pings.
    #
    undef_method :port=

    # Creates and returns a new Ping::ICMP object.  This is similar to its
    # superclass constructor, but must be created with root privileges (on
    # UNIX systems), and the port value is ignored.
    #
    def initialize(host=nil, port=nil, timeout=5)
      raise 'requires root privileges' if Process.euid > 0

      if File::ALT_SEPARATOR
        unless Win32::Security.elevated_security?
          raise 'requires elevated security'
        end
      end

      super(host, port, timeout)

      @port = nil # This value is not used in ICMP pings.
    end

    # Pings the +host+ specified in this method or in the constructor.  If a
    # host was not specified either here or in the constructor, an
    # ArgumentError is raised.
    #
    def ping(host = @host)
      super(host)
      bool = false

      inet = java.net.InetAddress
      addr = inet.get_all_by_name(host).first

      start_time = Time.now

      begin
        bool = addr.is_reachable?(timeout * 1000)
      rescue NativeException => err
        bool = false
        @exception = err
      end

      # There is no duration if the ping failed
      @duration = Time.now - start_time if bool

      return bool
    end

    alias ping? ping
    alias pingecho ping
  end
end

if $0 == __FILE__
  host = 'google.com'
  host = '127.0.0.1'
  host = '74.125.193.102'
  icmp = Net::Ping::ICMP.new(host)
  p icmp.ping?
end
