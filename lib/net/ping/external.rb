require 'open3'
require 'rbconfig'
require 'win32ole' if File::ALT_SEPARATOR

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
    def ping(host = @host)
      super(host)

      stdin = stdout = stderr = nil
      pcmd    = ["ping"]
      bool    = false
      orig_cp = nil

      case RbConfig::CONFIG['host_os']
        when /linux|bsd|osx|mach|darwin/i
          pcmd += ['-c1', host]
        when /solaris|sunos/i
          pcmd += [host, '1']
        when /hpux/i
          pcmd += [host, '-n1']
        when /win32|windows|msdos|mswin|cygwin|mingw/i
          orig_cp = WIN32OLE.codepage
          WIN32OLE.codepage = 437 if orig_cp != 437 # United States
          pcmd += ['-n', '1', host]
        else
          pcmd += [host]
      end

      start_time = Time.now

      begin
        err = nil

        Timeout.timeout(@timeout){
          stdin, stdout, stderr = Open3.popen3(*pcmd)
          err = stderr.gets # Can't chomp yet, might be nil
        }

        stdin.close
        stderr.close

        if File::ALT_SEPARATOR && WIN32OLE.codepage != orig_cp
          WIN32OLE.codepage = orig_cp
        end

        unless err.nil?
          if err =~ /warning/i
            @warning = err.chomp
            bool = true
          else
            @exception = err.chomp
          end
        # The "no answer" response goes to stdout, not stderr, so check it
        else
          lines = stdout.readlines
          stdout.close
          if lines.nil? || lines.empty?
            bool = true
          else
            regexp = /
              no\ answer|
              host\ unreachable|
              could\ not\ find\ host|
              request\ timed\ out|
              100%\ packet\ loss
            /ix

            lines.each{ |line|
              if regexp.match(line)
                @exception = line.chomp
                break
              end
            }

            bool = true unless @exception
          end
        end
      rescue Exception => error
        @exception = error.message
      ensure
        stdin.close  if stdin  && !stdin.closed?
        stdout.close if stdout && !stdout.closed?
        stderr.close if stderr && !stderr.closed?
      end

      # There is no duration if the ping failed
      @duration = Time.now - start_time if bool

      bool
    end

    alias ping? ping
    alias pingecho ping
  end
end
