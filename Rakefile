require 'rake'
require 'rake/testtask'
include Config

desc "Install the net-ping package (non-gem)"
task :install do
   dest1 = File.join(CONFIG['sitelibdir'], 'net')
   dest2 = File.join(dest1, 'ping')

   Dir.mkdir(dest1) unless File.exists?(dest1)
   Dir.mkdir(dest2) unless File.exists?(dest2)

   FileUtils.cp('lib/net/ping.rb', dest1, :verbose => true)

   Dir['lib/net/ping/*.rb'].each{ |file|
      FileUtils.cp(file, dest2, :verbose => true)
   }
end

desc 'Create and install the net-ping gem'
task :gem_install => [:gem] do
   gem_file = Dir["*.gem"].first
   sh "gem install #{gem_file}"
end

desc 'Create the net-ping gem'
task :gem do
   spec = eval(IO.read('net-ping.gemspec'))
   Gem::Builder.new(spec).build
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
