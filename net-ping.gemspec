require 'rubygems'
require 'rbconfig'

Gem::Specification.new do |gem|
  gem.name      = 'net-ping'
  gem.version   = '1.4.0'
  gem.license   = 'Artistic 2.0'
  gem.author    = 'Daniel J. Berger'
  gem.email     = 'djberg96@gmail.com'
  gem.homepage  = 'http://www.rubyforge.org/projects/shards'
  gem.summary   = 'A ping interface for Ruby.'
  gem.test_file = 'test/test_net_ping.rb'
  gem.has_rdoc  = true
  gem.files     = Dir['**/*'].reject{ |f| f.include?('git') }

  gem.rubyforge_project = 'shards'
  gem.extra_rdoc_files  = ['README', 'CHANGES', 'doc/ping.txt']

  gem.add_development_dependency('test-unit', '>= 2.1.2')

  # These dependencies are for Net::Ping::External
  if Config::CONFIG['host_os'] =~ /mswin|dos|win32|windows|cygwin|mingw/i &&
    RUBY_PLATFORM != 'java'
  then
    gem.platform = Gem::Platform::CURRENT
    gem.add_dependency('windows-pr', '>= 1.0.8')

    if RUBY_VERSION.to_f < 1.9
      gem.add_dependency('win32-open3', '>= 0.3.1') 
    end
  end

  gem.description = <<-EOF
    The net-ping library provides a ping interface for Ruby. It includes
    separate TCP, HTTP, ICMP, UDP, WMI (for Windows) and external ping
    classes.
  EOF
end
