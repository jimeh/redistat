require "rubygems"

require "spec"
require "spec/rake/spectask"

REDIS_DIR = File.expand_path(File.join("..", "spec"), __FILE__)
REDIS_CNF = File.join(REDIS_DIR, "redis-test.conf")
REDIS_PID = File.join(REDIS_DIR, "db", "redis.pid")


task :default => [:start, :spec, :stop]


# define the spec task
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = %w(--format specdoc --colour)
  t.libs = ["spec"]
end


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