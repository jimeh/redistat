require 'bundler'
Bundler::GemHelper.install_tasks


#
# Rspec
#

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => [:start, :spec, :stop]


#
# Start/stop Redis test server
#

REDIS_DIR = File.expand_path(File.join("..", "spec"), __FILE__)
REDIS_CNF = File.join(REDIS_DIR, "redis-test.conf")
REDIS_PID = File.join(REDIS_DIR, "db", "redis.pid")

desc "Start the Redis test server"
task :start do
  unless File.exists?(REDIS_PID)
    system "redis-server #{REDIS_CNF}"
  end
end

desc "Stop the Redis test server"
task :stop do
  if File.exists?(REDIS_PID)
    system "kill #{File.read(REDIS_PID)}"
    system "rm #{REDIS_PID}"
  end
end


#
# Yard
#

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end


#
# Misc.
#

desc "Start an irb console with TimeExt pre-loaded."
task :console do
  exec "irb -r spec/spec_helper"
end
task :c => :console
