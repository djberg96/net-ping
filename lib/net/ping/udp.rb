require File.join(File.dirname(__FILE__), 'ping')

# The Net module serves as a namespace only.
module Net

  # The Ping::UDP class encapsulates methods for UDP pings.
  class Ping::UDP < Ping
    @@service_check = true
      
    # Returns whether or not the connect behavior should enforce remote
    # service availability as well as reachability. The default is true.
    #
    def self.service_check
      @@service_check
    end
      
    # Set whether or not the connect behavior should enforce remote
    # service availability as well as reachability. If set to false
    # then Errno::ECONNREFUSED or Errno::ECONNRESET will be considered
    # a successful ping, meaning no actual data handshaking is required.
    # By default, if either of those errors occurs it is considered a failed
    # ping.
    #
    def self.service_check=(bool)
      unless bool.kind_of?(TrueClass) || bool.kind_of?(FalseClass)
        raise ArgumentError, 'argument must be true or false'
      end
      @@service_check = bool         
    end
      
    # The maximum data size that can be sent in a UDP ping.
    MAX_DATA = 64
      
    # The data to send to the remote host. By default this is 'ping'.
    # This should be MAX_DATA size characters or less.
    # 
    attr_reader :data
      
    # Creates and returns a new Ping::UDP object.  This is effectively
    # identical to its superclass constructor.
    # 
    def initialize(host=nil, port=nil, timeout=5)
      @data = 'ping'

      super(host, port, timeout)

      @bind_host = nil
      @bind_port = nil
    end
      
    # Sets the data string sent to the remote host. This value cannot have
    # a size greater than MAX_DATA.
    # 
    def data=(string)
       if string.size > MAX_DATA
         err = "cannot set data string larger than #{MAX_DATA} characters"
         raise ArgumentError, err
       end
         
       @data = string
    end

    # Associates the local end of the UDP connection with the given +host+
    # and +port+. This is essentially a wrapper for UDPSocket#bind.
    #
    def bind(host, port)
      @bind_host = host
      @bind_port = port
    end

    # Sends a simple text string to the host and checks the return string. If
    # the string sent and the string returned are a match then the ping was
    # successful and true is returned. Otherwise, false is returned.
    #
    def ping(host = @host)
      super(host)

      bool  = false
      udp   = UDPSocket.open
      array = []

      if @bind_host
        udp.bind(@bind_host, @bind_port)
      end

      start_time = Time.now

      begin
        Timeout.timeout(@timeout){
          udp.connect(host, @port)
          udp.send(@data, 0)
          array = udp.recvfrom(MAX_DATA)
        }
      rescue Errno::ECONNREFUSED, Errno::ECONNRESET => err
        if @@service_check
          @exception = err
        else
          bool = true
        end
      rescue Exception => err
        @exception = err
      else
        if array[0] == @data
          bool = true
        end
      ensure
        udp.close if udp
      end

      # There is no duration if the ping failed
      @duration = Time.now - start_time if bool

      bool
    end

    alias ping? ping
    alias pingecho ping
  end
end
