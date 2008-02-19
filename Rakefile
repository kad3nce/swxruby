require 'config/requirements'
require 'config/hoe' # setup Hoe + all gem configuration

Dir['tasks/**/*.rake'].each { |rake| load rake }

Rake::RDocTask.new(:rdoccy) do |rdoc|
  rdoc.options << '-d' if RUBY_PLATFORM !~ /win32/ and `which dot` =~ /\/dot/ and not ENV['NODOT']
  rdoc.rdoc_dir = 'doc'
  files = File.read("Manifest.txt").delete("\r").split(/\n/).grep(/^(lib|bin|ext)|README|CHANGELOG|LICENSE$/)
  files -= ['Manifest.txt']
  rdoc.rdoc_files.push(*files)

  title = "SWX Ruby: The Ruby Implementation of SWX RPC"
  rdoc.options << "-t #{title}"
end
