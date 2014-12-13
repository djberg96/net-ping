# By doing a "require 'net/ping'" you are requiring every subclass.  If you
# want to require a specific ping type only, do "require 'net/ping/tcp'",
# for example.
#
require 'rbconfig'

require_relative 'ping/tcp'
require_relative 'ping/udp'
require_relative 'ping/icmp'
require_relative 'ping/external'
require_relative 'ping/http'

RbConfig = Config unless Object.const_defined?(:RbConfig)

if File::ALT_SEPARATOR
  require_relative 'ping/wmi'
end
