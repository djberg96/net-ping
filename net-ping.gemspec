require 'rubygems'
require 'rbconfig'

Gem::Specification.new do |spec|
  spec.name      = 'net-ping'
  spec.version   = '1.7.6'
  spec.license   = 'Artistic 2.0'
  spec.author    = 'Daniel J. Berger'
  spec.email     = 'djberg96@gmail.com'
  spec.homepage  = 'https://github.com/djberg96/net-ping'
  spec.summary   = 'A ping interface for Ruby.'
  spec.test_file = 'test/test_net_ping.rb'
  spec.files     = Dir['**/*'].reject{ |f| f.include?('git') }

  spec.extra_rdoc_files  = ['README', 'CHANGES', 'doc/ping.txt']

  # The TCP Ping class requires this for non-blocking sockets.
  spec.required_ruby_version = ">= 1.9.3"

  spec.add_development_dependency('test-unit')
  spec.add_development_dependency('fakeweb')
  spec.add_development_dependency('rake')

  if File::ALT_SEPARATOR
    require 'rbconfig'
    arch = RbConfig::CONFIG['build_os'] || 'mingw32' # JRuby
    spec.platform = Gem::Platform.new(['universal', arch])
    spec.platform.version = nil

    # Used for icmp pings.
    spec.add_dependency('win32-security', '>= 0.2.0')
  end

  spec.description = <<-EOF
    The net-ping library provides a ping interface for Ruby. It includes
    separate TCP, HTTP, LDAP, ICMP, UDP, WMI (for Windows) and external ping
    classes.
  EOF
end
