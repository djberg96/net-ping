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
         tcp = nil
         start_time = Time.now

         begin
            Timeout.timeout(@timeout){
               begin
                  tcp = TCPSocket.new(host, @port)
               rescue Errno::ECONNREFUSED => err
                  if @@service_check
                     bool = true
                  else
                     @exception = err
                  end
               rescue Exception => err
                  @exception = err
               else
                  bool = true
               end
            }
         rescue Timeout::Error => err
            @exception = err
         ensure
            tcp.close if tcp
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
