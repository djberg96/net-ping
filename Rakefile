require 'rake'
require 'rake/clean'
require 'rake/testtask'
include Object.const_defined?(:RbConfig) ? RbConfig : Config

CLEAN.include("**/*.gem", "**/*.rbc")

namespace 'gem' do
  desc 'Create the net-ping gem'
  task :create => [:clean] do
    spec = eval(IO.read('net-ping.gemspec'))
    if Gem::VERSION.to_f < 2.0
      Gem::Builder.new(spec).build
    else
      require 'rubygems/package'
      Gem::Package.build(spec)
    end
  end

  desc 'Install the net-ping gem'
  task :install => [:create] do
    gem_file = Dir["*.gem"].first
    if RUBY_PLATFORM == 'java'
      sh "jruby -S gem install -l #{gem_file}"
    else
      sh "gem install -l #{gem_file}"
    end
  end
end

namespace 'example' do
  desc 'Run the external ping example program'
  task :external do
     ruby '-Ilib examples/example_pingexternal.rb'
  end

  desc 'Run the http ping example program'
  task :http do
     ruby '-Ilib examples/example_pinghttp.rb'
  end

  desc 'Run the tcp ping example program'
  task :tcp do
     ruby '-Ilib examples/example_pingtcp.rb'
  end

  desc 'Run the udp ping example program'
  task :udp do
     ruby '-Ilib examples/example_pingudp.rb'
  end
end

Rake::TestTask.new do |t|
   t.libs << 'test'
   t.warning = true
   t.verbose = true
   t.test_files = FileList['test/test_net_ping.rb']
end

namespace 'test' do
  Rake::TestTask.new('external') do |t|
     t.warning = true
     t.verbose = true
     t.test_files = FileList['test/test_net_ping_external.rb']
  end

  Rake::TestTask.new('http') do |t|
     t.warning = true
     t.verbose = true
     t.test_files = FileList['test/test_net_ping_http.rb']
  end

  Rake::TestTask.new('icmp') do |t|
     t.warning = true
     t.verbose = true
     t.test_files = FileList['test/test_net_ping_icmp.rb']
  end

  Rake::TestTask.new('tcp') do |t|
     t.warning = true
     t.verbose = true
     t.test_files = FileList['test/test_net_ping_tcp.rb']
  end

  Rake::TestTask.new('udp') do |t|
     t.warning = true
     t.verbose = true
     t.test_files = FileList['test/test_net_ping_udp.rb']
  end

  Rake::TestTask.new('wmi') do |t|
     t.warning = true
     t.verbose = true
     t.test_files = FileList['test/test_net_ping_wmi.rb']
  end
end

task :default => :test
