require 'open3'
require 'rbconfig'

require File.join(File.dirname(__FILE__), 'ping')

# The Net module serves as a namespace only.
module Net

  # The Ping::External class encapsulates methods for external (system) pings.
  class Ping::External < Ping
    # Pings the host using your system's ping utility and checks for any
    # errors or warnings. Returns true if successful, or false if not.
    #
    # If the ping failed then the Ping::External#exception method should
    # contain a string indicating what went wrong. If the ping succeeded then
    # the Ping::External#warning method may or may not contain a value.
    #
    def ping(host = @host, count = 1, interval = 1, timeout = @timeout)

      raise "Count must be an integer" unless count.is_a? Integer
      raise "Timeout must be a number" unless timeout.is_a? Numeric

      unless interval.is_a?(Numeric) && interval >= 0.2
        raise "Interval must be a decimal greater than or equal to 0.2"
      end

      super(host)

      pcmd = ['ping']
      bool = false

      case RbConfig::CONFIG['host_os']
        when /linux/i
          pcmd += ['-c', count.to_s, '-W', timeout.to_s, host, '-i', interval.to_s]
        when /aix/i
          pcmd += ['-c', count.to_s, '-w', timeout.to_s, host]
        when /bsd|osx|mach|darwin/i
          pcmd += ['-c', count.to_s, '-t', timeout.to_s, host]
        when /solaris|sunos/i
          pcmd += [host, timeout.to_s]
        when /hpux/i
          pcmd += [host, "-n#{count.to_s}", '-m', timeout.to_s]
        when /win32|windows|msdos|mswin|cygwin|mingw/i
          pcmd += ['-n', count.to_s, '-w', (timeout * 1000).to_s, host]
        else
          pcmd += [host]
      end

      start_time = Time.now

      begin
        err = nil

        Open3.popen3(*pcmd) do |stdin, stdout, stderr, thread|
          stdin.close
          err = stderr.gets # Can't chomp yet, might be nil

          case thread.value.exitstatus
            when 0
              info = stdout.read
              if info =~ /unreachable/ix # Windows
                bool = false
                @exception = "host unreachable"
              else
                bool = true  # Success, at least one response.
              end

              if err & err =~ /warning/i
                @warning = err.chomp
              end
            when 2
              bool = false # Transmission successful, no response.
              @exception = err.chomp if err
            else
              bool = false # An error occurred
              if err
                @exception = err.chomp
              else
                stdout.each_line do |line|
                  if line =~ /(timed out|could not find host|packet loss)/i
                    @exception = line.chomp
                    break
                  end
                end
              end
          end
        end
      rescue Exception => error
        @exception = error.message
      end

      # There is no duration if the ping failed
      @duration = Time.now - start_time if bool

      bool
    end

    alias ping? ping
    alias pingecho ping
  end
end
