require 'rubygems'
require 'rbconfig'

Gem::Specification.new do |spec|
  spec.name      = 'net-ping'
  spec.version   = '1.6.0'
  spec.license   = 'Artistic 2.0'
  spec.author    = 'Daniel J. Berger'
  spec.email     = 'djberg96@gmail.com'
  spec.homepage  = 'https://github.com/djberg96/net-ping'
  spec.summary   = 'A ping interface for Ruby.'
  spec.test_file = 'test/test_net_ping.rb'
  spec.files     = Dir['**/*'].reject{ |f| f.include?('git') }

  spec.rubyforge_project = 'shards'
  spec.extra_rdoc_files  = ['README', 'CHANGES', 'doc/ping.txt']

  spec.add_dependency('ffi', '>= 1.0.0')

  spec.add_development_dependency('test-unit', '>= 2.5.0')
  spec.add_development_dependency('fakeweb', '>= 1.3.0')

  if File::ALT_SEPARATOR && RUBY_PLATFORM != 'java'
    spec.platform = Gem::Platform::CURRENT
    spec.platform.cpu = 'universal'
    spec.platform.version = nil

    # Used primarily for icmp pings.
    spec.add_development_dependency('win32-security', '>= 0.2.0')

    if RUBY_VERSION.to_f < 1.9
      spec.add_dependency('win32-open3', '>= 0.3.1')
    end
  end

  spec.description = <<-EOF
    The net-ping library provides a ping interface for Ruby. It includes
    separate TCP, HTTP, LDAP, ICMP, UDP, WMI (for Windows) and external ping
    classes.
  EOF
end
