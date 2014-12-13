require File.join(File.dirname(__FILE__), 'ping')

# The Net module serves as a namespace only.
module Net

  # With a TCP ping simply try to open a connection. If we are successful,
  # assume success. In either case close the connection to be polite.
  #
  class Ping::TCP < Ping
    @@service_check = false

    # Returns whether or not Errno::ECONNREFUSED is considered a successful
    # ping. The default is false.
    #
    def self.service_check
      @@service_check
    end

    # Sets whether or not an Errno::ECONNREFUSED should be considered a
    # successful ping.
    #
    def self.service_check=(bool)
      unless bool.kind_of?(TrueClass) || bool.kind_of?(FalseClass)
        raise ArgumentError, 'argument must be true or false'
      end
      @@service_check = bool
    end

    # This method attempts to ping a host and port using a TCPSocket with
    # the host, port and timeout values passed in the constructor.  Returns
    # true if successful, or false otherwise.
    #
    # Note that, by default, an Errno::ECONNREFUSED return result will be
    # considered a failed ping.  See the documentation for the
    # Ping::TCP.service_check= method if you wish to change this behavior.
    #
    def ping(host=@host)
      super(host)

      bool = false
      start_time = Time.now

      # Failure here most likely means bad host, so just bail.
      begin
        addr = Socket.getaddrinfo(host, port)
      rescue SocketError => err
        @exception = err
        return false
      end

      begin
        # Where addr[0][0] is likely AF_INET.
        sock = Socket.new(Socket.const_get(addr[0][0]), Socket::SOCK_STREAM, 0)

        # This may not be entirely necessary
        sock.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)

        begin
          # Where addr[0][3] is an IP address
          sock.connect_nonblock(Socket.pack_sockaddr_in(port, addr[0][3]))
        rescue Errno::EINPROGRESS
          # No-op, continue below
        rescue Exception => err
          # Something has gone horribly wrong
          @exception = err
          return false
        end

        resp = IO.select(nil, [sock], nil, timeout)

        if resp.nil? # Assume ECONNREFUSED if nil
          if @@service_check
            bool = true
          else
            bool = false
            @exception = Errno::ECONNREFUSED
          end
        else
          sockopt = sock.getsockopt(Socket::SOL_SOCKET, Socket::SO_ERROR)

          if sockopt.int != 0
            if @@service_check && sockopt.int == Errno::ECONNREFUSED::Errno
              bool = true
            else
              bool = false
              @exception = SystemCallError.new(sockopt.int)
            end
          else
            bool = true
          end
        end
      ensure
        sock.close if sock
      end

      # There is no duration if the ping failed
      @duration = Time.now - start_time if bool

      bool
    end

    alias ping? ping
    alias pingecho ping

    # Class method aliases. DEPRECATED.
    class << self
      alias econnrefused service_check
      alias econnrefused= service_check=
      alias ecr service_check
      alias ecr= service_check=
    end
  end
end
