require 'socket'
require 'timeout'

# The Net module serves as a namespace only.
#
module Net

   # The Ping class serves as an abstract base class for all other Ping class
   # types. You should not instantiate this class directly.
   #
   class Ping
      # The version of the net-ping library.
      VERSION = '1.7.6'

      # The host to ping. In the case of Ping::HTTP, this is the URI.
      attr_accessor :host

      # The port to ping. This is set to the echo port (7) by default. The
      # Ping::HTTP class defaults to port 80.
      #
      attr_accessor :port

      # The maximum time a ping attempt is made.
      attr_accessor :timeout

      # If a ping fails, this value is set to the error that occurred which
      # caused it to fail.
      #
      attr_reader :exception

      # This value is set if a ping succeeds, but some other condition arose
      # during the ping attempt which merits warning, e.g a redirect in the
      # case of Ping::HTTP#ping.
      #
      attr_reader :warning

      # The number of seconds (returned as a Float) that it took to ping
      # the host. This is not a precise value, but rather a good estimate
      # since there is a small amount of internal calculation that is added
      # to the overall time.
      #
      attr_reader :duration

      # The default constructor for the Net::Ping class.  Accepts an optional
      # +host+, +port+ and +timeout+.  The port defaults to your echo port, or
      # 7 if that happens to be undefined.  The default timeout is 5 seconds.
      #
      # The host, although optional in the constructor, must be specified at
      # some point before the Net::Ping#ping method is called, or else an
      # ArgumentError will be raised.
      #
      # Yields +self+ in block context.
      #
      # This class is not meant to be instantiated directly.  It is strictly
      # meant as an interface for subclasses.
      #
      def initialize(host=nil, port=nil, timeout=5)
         @host      = host
         @port      = port || Socket.getservbyname('echo') || 7
         @timeout   = timeout
         @exception = nil
         @warning   = nil
         @duration  = nil

         yield self if block_given?
      end

      # The default interface for the Net::Ping#ping method.  Each subclass
      # should call super() before continuing with their own implementation in
      # order to ensure that the @exception and @warning instance variables
      # are reset.
      #
      # If +host+ is nil here, then it will use the host specified in the
      # constructor.  If the +host+ is nil and there was no host specified
      # in the constructor then an ArgumentError is raised.
      #--
      # The @duration should be set in the subclass' ping method.
      #
      def ping(host = @host)
         raise ArgumentError, 'no host specified' unless host
         @exception = nil
         @warning   = nil
         @duration  = nil
      end

      alias ping? ping
      alias pingecho ping
   end
end
